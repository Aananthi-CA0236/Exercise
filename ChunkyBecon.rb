require 'date'
require 'time'

class BusinessHours

	attr_reader :start_time, :end_time
	@@special_days={}
	@@closed_days=[]
	@@week_days=["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]

	def initialize(start_time,end_time)
		@start_time=Time.parse(start_time)
		@end_time=Time.parse(end_time)
	end
	def update(day, start_time, end_time)
		if @@week_days.member?day.capitalize
			@@special_days[day.capitalize]=[Time.parse(start_time),Time.parse(end_time)]
		elsif Date.parse(day)
			@@special_days[Date.parse(day)]=[Time.parse(start_time),Time.parse(end_time)]
		end
	end
	def closed(*days)
		days.each do |day|
			if @@week_days.member?day.capitalize
				puts day
				@@closed_days.push(day.capitalize)
			elsif Date.parse(day)
				@@closed_days.push(Date.parse(day))
			end
		end
	end
	def calculate_deadline(time_needed,time_given)
		puts "calculate_deadline" 
		time_given = DateTime.parse(time_given)
		date_found=false
		while !date_found
			puts "-------time given -----"
			puts time_given
			current_start_time =DateTime.new(time_given.year,time_given.month,time_given.day,start_time.strftime("%k").to_i,start_time.strftime("%M").to_i)	
			current_end_time=DateTime.new(time_given.year,time_given.month,time_given.day,end_time.strftime("%k").to_i,end_time.strftime("%M").to_i)	

			#checking is present date is closed. If so, add one day to the given date. 
			#e.g, Jun 7,2010(Mon) ->closed date. We add one day and set hour and minute to 00:00 -->jun 8,2010 00:00

			if is_closed_day(time_given)
				time_given  = add_one_day(time_given)
				next
			end 

			#checking is the present date is special date with different start and end time. If it is so, update the current_start_time and current_end_time
			if is_special_day(time_given)
				if @@special_days.has_key?(time_given.strftime("%a"))
					key= week_day
				else
					key=time_given
				end
				current_start_time =DateTime.new(time_given.year,time_given.month,time_given.day,@@special_days[key][0].strftime("%k").to_i,@@special_days[key][0].strftime("%M").to_i)	
				current_end_time =DateTime.new(time_given.year,time_given.month,time_given.day,@@special_days[key][1].strftime("%k").to_i,@@special_days[key][1].strftime("%M").to_i)	
			end
			
			#checking if the given time is prior to the shop opening time. If it is so, we will update the time to opening time (since we consider only working hours)
			if time_given.strftime( "%H%M%S%N" ) < current_start_time.strftime( "%H%M%S%N" )	
				time_given=DateTime.new(time_given.year,time_given.month,time_given.day,current_start_time.strftime("%k").to_i,current_start_time.strftime("%M").to_i)	
			end

			#checking whether the given time is after shop closing time. If is so, then we update the time to next day with 00:00 time
			if time_given.strftime( "%H%M%S%N" ) > current_end_time.strftime( "%H%M%S%N" )	
				time_given  = add_one_day(time_given)
			end

			#if we have time remaining from previous executing, we will consider that. Else, total time_needed value is considered
			if @remaining_time==nil
				new_time = time_given.to_time+time_needed
			else
				new_time = time_given.to_time+@remaining_time
			end
			
			#if processed time(new_time) is less than shop closing time, we can return the value, else add remaining time and continue the process 
			if new_time.strftime( "%H%M%S%N" ) <= current_end_time.strftime( "%H%M%S%N" )
				date_found=true
				result_date = new_time	
			else
				@remaining_time=new_time.to_time - current_end_time.to_time
				time_given  = add_one_day(time_given)
			end
			
		end
		return result_date
	end
	def is_special_day(day)
		week_day = day.strftime("%a")
		@@special_days.has_key?(week_day) || @@special_days.has_key?(day)
	end
	def is_closed_day(day)	
		week_day =day.strftime("%a")
		@@closed_days.include?(week_day) || @@closed_days.include?(day)
	end
	def add_one_day(date_time)
		date_time = date_time.next_day(1)
		return DateTime.new(date_time.year, date_time.month, date_time.day,0,0)
	end	
end

b= BusinessHours.new("10:00 AM","3:00 PM")
b.update("fri", "12:00 PM", "5:00 PM")
b.update("Jun 9, 2010", "8:00 AM", "1:00 PM")
b.closed("Mon","Tue","Dec 25, 2010")
#puts b.is_special_day("Dec 24, 2010")
#puts b.is_closed_day("Dec 24, 2010")
puts b.calculate_deadline(39600,"Jun 7, 2010 9:10 AM")
