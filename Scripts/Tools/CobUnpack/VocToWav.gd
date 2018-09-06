const RiffChunk = preload("res://Scripts/Tools/CobUnpack/WavStructs.gd").RiffChunk
const FormatChunk = preload("res://Scripts/Tools/CobUnpack/WavStructs.gd").FormatChunk
const DataChunk = preload("res://Scripts/Tools/CobUnpack/WavStructs.gd").DataChunk

enum VocBlockType { Terminator, SoundData, SoundDataContinuation, Silence, Marker, Text, StartRepetition, EndRepetition, ExtraInfo, SoundData2 }

static func is_voc(source):
	var file = File.new()
	var status = file.open(source, File.READ)
	if status == OK:
		var ident_bytes = file.get_buffer(19)
		var ident_stream = StreamPeerBuffer.new()
		ident_stream.set_data_array(ident_bytes)
		var ident = ident_stream.get_string(19)
		if ident != "Creative Voice File":
			#prints(source,"is not a voc file", str(ident[0]))
			file.close()
			return false
		else:
			file.close()
			return true

static func unvoc(source):
	var file = File.new()
	var status = file.open(source, File.READ)
	if status == OK:
		# skip the VOC ident
		var ident = file.get_buffer(19)
		var eof = file.get_buffer(1)

		# get the header size
		var main_header_size = file.get_16()

		# get the version
		var v_minor = file.get_8()
		var v_major = file.get_8()
		# get validation
		var validity = file.get_16()

		# block type storage
		var voc_block_type
		
		# voc block info
		var size = 0
		var sample_rate = 0
		var frequency_divisor = 0
		var bits_per_sample = 0
		var channel_count = 0
		var codec = 0
		var wav_codec = 0
		var bytes_per_sample = 0

		# data stream
		var data = []

		while file.get_pos() < file.get_len():
			voc_block_type = file.get_8()
			if voc_block_type == VocBlockType.Terminator:
				break

			if voc_block_type == VocBlockType.SoundData:
				size = file.get_16()
				frequency_divisor = file.get_8()
				codec = file.get_8()

				data = file.get_buffer(size - 2)

				sample_rate = 1000000 / (256 - frequency_divisor)

				wav_codec = 1
				channel_count = 1
				bits_per_sample = 8
				bytes_per_sample = 1
				break
			elif voc_block_type == VocBlockType.SoundData2:
				var size_byte1 = file.get_8()
				var size_byte2 = file.get_8()
				var size_byte3 = file.get_8()
				size = size_byte1 | size_byte2 << 8 | size_byte3 << 16

				sample_rate = file.get_32()
				bits_per_sample = file.get_8()
				channel_count = file.get_8()
				codec = file.get_16()
				var skip = file.get_32()
				data = file.get_buffer(size - 12)

				wav_codec = 1
				bytes_per_sample = 1
				break
			pass

		# get a RIFF chunk
		var riff = RiffChunk.new()
		riff.setup()

		# set up the RIFF size info
		riff.total_size = 12 + 24 + 8 + data.size() - 8

		# prepare the wav stream peer buffer
		var wav_stream = StreamPeerBuffer.new()
		wav_stream.put_data(riff.id)
		wav_stream.put_u32(riff.total_size)
		wav_stream.put_data(riff.type)

		var format = FormatChunk.new()
		format.setup()
		format.codec = wav_codec
		format.channel_count = channel_count
		format.sample_rate = sample_rate
		format.bytes_per_second = sample_rate
		format.bytes_per_sample = bytes_per_sample
		format.bits_per_sample = bits_per_sample

		wav_stream.put_data(format.id)
		wav_stream.put_u32(format.size)
		wav_stream.put_u16(format.codec)
		wav_stream.put_u16(format.channel_count)
		wav_stream.put_u32(format.sample_rate)
		wav_stream.put_u32(format.bytes_per_second)
		wav_stream.put_u16(format.bytes_per_sample)
		wav_stream.put_u16(format.bits_per_sample)

		var wav_data = DataChunk.new()
		wav_data.setup()
		wav_data.size = data.size()

		wav_stream.put_data(wav_data.id)
		wav_stream.put_u32(wav_data.size)
		wav_stream.put_data(RawArray(data))

		file.close()
		return wav_stream
	pass

static func store(source, wav_stream):
	var raw_stream_array = wav_stream.get_data_array()
	var write_file_path = source.replace(".voc", ".wav")
	var write_file = File.new()
	write_file.open(write_file_path, File.WRITE)
	write_file.store_buffer(raw_stream_array)
	write_file.close()
