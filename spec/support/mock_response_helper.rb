module MockApiResponseHelper
  class MockSquareApiResponse
    def errors
      nil
    end

    def data
      self
    end

    def payment
      { 
        id: 42,
        receipt_url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      }
    end
  end
end