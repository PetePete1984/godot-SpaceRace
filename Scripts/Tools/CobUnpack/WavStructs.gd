class RiffChunk:
	var id # char array
	var total_size # file size - header (8 bytes)
	var type # char array

	func setup():
		id = RawArray(['R'.ord_at(0), 'I'.ord_at(0), 'F'.ord_at(0), 'F'.ord_at(0)])
		type = RawArray(['W'.ord_at(0), 'A'.ord_at(0), 'V'.ord_at(0), 'E'.ord_at(0)])

class FormatChunk:
	var id
	var size
	var codec
	var channel_count
	var sample_rate
	var bytes_per_second
	var bytes_per_sample
	var bits_per_sample

	func setup():
		id = RawArray(['f'.ord_at(0), 'm'.ord_at(0), 't'.ord_at(0), ' '.ord_at(0)])
		size = 0x10
		codec = 0x01

class DataChunk:
	var id
	var size

	func setup():
		id = RawArray(['d'.ord_at(0), 'a'.ord_at(0), 't'.ord_at(0), 'a'.ord_at(0)])
		