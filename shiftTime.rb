require 'time'
	
#Class to perform operation related to timecode in the srt file
class TimeCode
	def initialize(hours,minutes,seconds,milliSeconds)
		@time= Time.new(Time.now.year, Time.now.month, Time.now.day, hours.to_i, minutes.to_i, seconds.to_i)
		@milliSeconds= milliSeconds.to_i
  	end
	#shift the timecode by given seconds and milliseconds
  	def shiftTimeCode(shiftSeconds,shiftMilliSeconds)
		@time += shiftSeconds.to_i
		newMilliSeconds = @milliSeconds.to_i + shiftMilliSeconds.to_i
		if newMilliSeconds>1000
			secondsToBeAdded = newMilliSeconds/1000
			@milliSeconds = newMilliSeconds%1000
		elsif newMilliSeconds<0
			secondsToBeSubtracted = (newMilliSeconds.abs/1000)+1
			@milliSeconds = 1000-( newMilliSeconds.abs%1000)
		else
			@milliSeconds= newMilliSeconds
		end
		@time += secondsToBeAdded if secondsToBeAdded!=nil
		@time -= secondsToBeSubtracted if secondsToBeSubtracted!=nil
  	end  
	#To get timecode is required output format
  	def getTimeStampAsString()
    		return '%02d'%@time.hour.to_s+":"+'%02d'%@time.min.to_s+":"+'%02d'%@time.sec.to_s+","+'%03d'%@milliSeconds.to_s
  	end 
end

class ShiftTime
	def validateAndGetInputSRTFile()	
		validFile=false
		while !validFile
			puts "Enter the input file name"
			@inputFile = gets.chomp
			if(!File.exist?(@inputFile))
  				puts 'File does not exist!'
			else	
				validFile=true
			end
		end
	end

	def validateAndGetShiftingInput
		validInput=false
		while !validInput
			puts "enter the time to be shifted. Format: ss,mmm[s-seconds,m-milliseconds]"
			shiftTime=gets.chomp
			if shiftTime.length>6 || shiftTime.match(/\d{1,2},\d{1,3}/)==nil
				puts "Invalid Input!"
				next
			end
			shiftTime = shiftTime.split(",")
			@shiftSeconds= shiftTime[0]
			@shiftMilliSeconds = shiftTime[1]
			validInput=true
		end
	end

	def processInputSRTFile
		outputFile = "output.txt"
		output= File.open(outputFile, "w") 
		File.foreach(@inputFile) { 
			|line|
			timecodes = line.split(" --> ")
			if timecodes.size ==1
				output.write(line)
			else
				firstCode=true
				timecodes.each do |timecode|
					validTimeCode=isValidTimeCode(timecode.strip).to_s
					if validTimeCode
						hours= validTimeCode[0..1]
  						minutes= validTimeCode[3..4]
  						seconds=validTimeCode[6..7]
 						milliSeconds= validTimeCode[9..11]
  						timeCode	=TimeCode.new(hours,minutes,seconds,milliSeconds)
						timeCode.shiftTimeCode(@shiftSeconds,@shiftMilliSeconds)
						shiftedTimeCode= timeCode.getTimeStampAsString()
						output.write(shiftedTimeCode)
						if firstCode
							output.write("  -->  ")
							firstCode =false
						else
							output.write("\n")
						end
		
					end
				end
			end
		}
		output.write
		puts "Successfully shifted time. Output file name : #{outputFile}"
	end
	
	def isValidTimeCode(timeStamp)
  		return timeStamp.match(/\d{2}:\d{2}:\d{2},\d{3}/)
	end
end
shiftTime = ShiftTime.new
shiftTime.validateAndGetInputSRTFile
shiftTime.validateAndGetShiftingInput
shiftTime.processInputSRTFile
