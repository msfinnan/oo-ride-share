require "csv"
require "time"

require_relative "csv_record"

module RideShare
  class Trip < CsvRecord
    attr_reader :id, :passenger, :passenger_id, :start_time, :end_time, :cost, :rating

    def initialize(id:,
                   passenger: nil, passenger_id: nil,
                   start_time:, end_time:, cost: nil, rating:)
      super(id)

      if passenger
        @passenger = passenger
        @passenger_id = passenger.id
      elsif passenger_id
        @passenger_id = passenger_id
      else
        raise ArgumentError, "Passenger or passenger_id is required"
      end

      @start_time = Time.parse(start_time)
      @end_time = Time.parse(end_time)
      @cost = cost
      @rating = rating
      if @start_time > @end_time
        raise ArgumentError, "No! The start time cannot be after the end time."
      end

      if @rating > 5 || @rating < 1
        raise ArgumentError.new("Invalid rating #{@rating}")
      end
    end

    def duration_in_seconds
      length_of_trip = @start_time - @end_time
      return length_of_trip
    end

    def inspect
      # Prevent infinite loop when puts-ing a Trip
      # trip contains a passenger contains a trip contains a passenger...
      "#<#{self.class.name}:0x#{self.object_id.to_s(16)} " +
      "ID=#{id.inspect} " +
      "PassengerID=#{passenger&.id.inspect}>"
    end

    def connect(passenger)
      @passenger = passenger
      passenger.add_trip(self)
    end

    private

    def self.from_csv(record)
      return self.new(
               id: record[:id],
               passenger_id: record[:passenger_id],
               start_time: record[:start_time],
               end_time: record[:end_time],
               cost: record[:cost],
               rating: record[:rating],
             )
    end
  end
end
