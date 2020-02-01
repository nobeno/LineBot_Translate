require 'line/bot'
require 'aws-sdk'

  def handler(event:, context:)
    body = event["body"]
    signature = event["headers"]["X-Line-Signature"]
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
    requests = client.parse_events_from(body)
    requests.each do |req|
      case req
      when Line::Bot::Event::Message
        case req.type
        when Line::Bot::Event::MessageType::Text
          mes = req.message['text']
          result = get_translate_text(mes)
          token = req['replyToken']
          message = {
            type: 'text',
            text: result
          }
          client.reply_message(token, message)
        end
      end
    end
  end
  
  def get_translate_text(mes)
        aws_client = Aws::Translate::Client.new(
            region: 'ap-northeast-1'
        )
        
        result = aws_client.translate_text({
            text: mes,
            source_language_code: 'ja',
            target_language_code: 'ru'
            })
        
        return result.translated_text
  end

  private 

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    }
  end