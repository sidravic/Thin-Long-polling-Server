
require 'rubygems'
require 'json'

class DPoll
	include EventMachine::Deferrable

	def each(&block)
		@callback_ex = block
	end

	def append_body(body_data, timer)
		body_data.each do |data_chunk|
			unless @callback_ex.nil?
				@callback_ex.call(data_chunk)
				succeed
				EM.cancel_timer timer
				puts "#{timer} cancelled"
			end
		end
	end
end

class LP
	AysncResponse = [-1, {}, []].freeze

	
	def call(env)
		puts env['']
		body = DPoll.new
		
		EM.next_tick {
			env['async.callback'].call([200, {'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => "*"}, body])			
		}

		random_number = rand(20)
		puts "Random number #{random_number}"
		
		t = EM.add_timer(random_number) do			
			body.append_body(['Hello...'], self)
		end

		EM.add_timer(10) do
			body.succeed
		end
		
		AysncResponse
	end
end

run LP.new