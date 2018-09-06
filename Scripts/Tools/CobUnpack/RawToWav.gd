const RiffChunk = preload("res://Scripts/Tools/CobUnpack/WavStructs.gd").RiffChunk
const FormatChunk = preload("res://Scripts/Tools/CobUnpack/WavStructs.gd").FormatChunk
const DataChunk = preload("res://Scripts/Tools/CobUnpack/WavStructs.gd").DataChunk

static func unraw(source):
	var riff = RiffChunk.new()
	riff.setup()

	var file = File.new()
	file.open(source, File.READ)

	riff.total_size = 12 + 24 + 8 + file.get_len() - 8
	var wav_buffer = []
	wav_buffer.resize(riff.total_size + 8)

	var wav_stream = StreamPeerBuffer.new()
	wav_stream.put_data(riff.id)
	wav_stream.put_u32(riff.total_size)
	wav_stream.put_data(riff.type)

	var format = FormatChunk.new()
	format.setup()
	format.codec = 1
	format.channel_count = 1
	format.sample_rate = 22050
	format.bytes_per_second = 22050
	format.bytes_per_sample = 1
	format.bits_per_sample = 8

	wav_stream.put_data(format.id)
	wav_stream.put_u32(format.size)
	wav_stream.put_u16(format.codec)
	wav_stream.put_u16(format.channel_count)
	wav_stream.put_u32(format.sample_rate)
	wav_stream.put_u32(format.bytes_per_second)
	wav_stream.put_u16(format.bytes_per_sample)
	wav_stream.put_u16(format.bits_per_sample)

	var data = DataChunk.new()
	data.setup()
	data.size = file.get_len()

	wav_stream.put_data(data.id)
	wav_stream.put_u32(data.size)
	wav_stream.put_data(file.get_buffer(file.get_len()))

	file.close()
	return wav_stream

static func store(source, wav_stream):
	var raw_stream_array = wav_stream.get_data_array()
	var write_file_path = source
	var write_file = File.new()
	write_file.open(write_file_path, File.WRITE)
	write_file.store_buffer(raw_stream_array)
	write_file.close()
	pass