module ExpertOpinionsHelper
  def class_for_opinion(opinion)
    return '' if opinion.vote.nil?
    return ' positive_opinion' if opinion.vote
    return ' negative_opinion' unless opinion.vote
  end
end
