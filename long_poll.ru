
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
		body = DPoll.new
		
		EM.next_tick {
			env['async.callback'].call([200, {'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => "*"}, body])			
		}

		EM.next_tick do
			random_number = rand(20)
			puts "Random number #{random_number}"			
			puts " = activating one shot timer ="
			t = EM.add_timer(random_number) do	
			    puts "-- One shot fired --"		
				body.append_body(['Hello...'], self)			
			end
		end

		EM.add_timer(10) do
			body.succeed
		end
		
		AysncResponse
	end
end

run LP.new