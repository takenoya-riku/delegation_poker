class MergeTopicsService
  include Service

  def call(source_topic_id:, target_topic_id:)
    source_topic = Topic.find_by(id: source_topic_id)
    target_topic = Topic.find_by(id: target_topic_id)

    return OpenStruct.new(success: false, topic: nil, errors: ['統合元のトピックが見つかりません']) unless source_topic
    return OpenStruct.new(success: false, topic: nil, errors: ['統合先のトピックが見つかりません']) unless target_topic

    unless source_topic.status == 'organizing' && target_topic.status == 'organizing'
      return OpenStruct.new(success: false, topic: nil, errors: ['整理フェーズのトピックのみ統合できます'])
    end

    unless source_topic.room_id == target_topic.room_id
      return OpenStruct.new(success: false, topic: nil, errors: ['同じルームのトピックのみ統合できます'])
    end

    # 統合先のトピックのタイトルと説明を更新（統合元の情報を追加）
    merged_title = "#{target_topic.title} / #{source_topic.title}"
    merged_description = [target_topic.description, source_topic.description].compact.join("\n\n")

    if target_topic.update(title: merged_title, description: merged_description)
      # 統合元のトピックを削除
      source_topic.destroy
      OpenStruct.new(success: true, topic: target_topic, errors: [])
    else
      OpenStruct.new(success: false, topic: target_topic, errors: target_topic.errors.full_messages)
    end
  end
end
