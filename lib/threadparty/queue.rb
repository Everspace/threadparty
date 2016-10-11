class Queue
	def to_a!
		a = Array.new
		while !empty?
			a.push pop()
		end
		a
	end
end