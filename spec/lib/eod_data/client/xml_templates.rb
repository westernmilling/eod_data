# frozen_string_literal: true

module EODData
  module XmlTemplates
    module Login
      FAILURE = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                       xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                       xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <LoginResponse xmlns="http://ws.eoddata.com/Data">
              <LoginResult Message="%<message>s"
                           Header="false"
                           Suffix="false" />
              </LoginResponse>
          </soap:Body>
        </soap:Envelope>
      XML
      SUCCESS = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                       xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                       xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <LoginResponse xmlns="http://ws.eoddata.com/Data">
              <LoginResult Message="%<message>s"
                           Token="%<token>s"
                           DataFormat="Spread"
                           Header="true"
                           Suffix="true" />
            </LoginResponse>
          </soap:Body>
        </soap:Envelope>
      XML
    end

    module QuoteGet
      SUCCESS = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                       xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                       xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <QuoteGetResponse xmlns="http://ws.eoddata.com/Data">
              <QuoteGetResult Source="Data.QuoteGet"
                              Message="%<message>s"
                              Date="0001-01-01T00:00:00">
                %<quote>s
              </QuoteGetResult>
            </QuoteGetResponse>
          </soap:Body>
        </soap:Envelope>
      XML
    end

    module QuoteListByDate
      SUCCESS = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                       xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                       xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <QuoteListByDateResponse xmlns="http://ws.eoddata.com/Data">
              <QuoteListByDateResult Source="Data.QuoteListByDate"
                              Message="%<message>s"
                              Date="0001-01-01T00:00:00">
                <QUOTES>
                  %<quotes>s
                </QUOTES>
              </QuoteListByDateResult>
            </QuoteListByDateResponse>
          </soap:Body>
        </soap:Envelope>
      XML
    end

    module QuoteList
      SUCCESS = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                       xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                       xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <QuoteList2Response xmlns="http://ws.eoddata.com/Data">
              <QuoteList2Result Source="Data.QuoteList2"
                              Message="%<message>s"
                              Date="0001-01-01T00:00:00">
                <QUOTES>
                  %<quotes>s
                </QUOTES>
              </QuoteList2Result>
            </QuoteList2Response>
          </soap:Body>
        </soap:Envelope>
      XML
    end

    QUOTE_ELEMENT = <<~XML
      <QUOTE Symbol="%<symbol>s"
             Description="%<description>s"
             Name="%<name>s"
             DateTime="%<date_time>s"
             Open="%<open>s"
             High="%<high>s"
             Low="%<low>s"
             Close="%<close>s"
             Volume="%<volume>s"
             OpenInterest="%<open_interest>s"
             Previous="%<previous>s"
             Change="%<change>s"
             Bid="%<bid>s"
             Ask="%<ask>s"
             PreviousClose="%<previous_close>s"
             NextOpen="%<next_open>s"
             Modified="%<modified>s" />
    XML
  end
end
