module Interactive
  require "net/http"

  def send_interactive_message(url)
    payload = {
      "blocks": [
        {
          "type": "actions",
          "elements": [
            {
              "type": "users_select",
              "placeholder": {
                "type": "plain_text",
                "text": "Bobby",
                "emoji": true,
              },
            },
          ],
        },
      ],
    }.to_json
    Net::HTTP.post(URI(url), payload)
  end
end
