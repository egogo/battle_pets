$LOAD_PATH.unshift File.dirname(__FILE__)

require 'bundler'

Bundler.require

require_relative '../../service_wrappers/service_wrapper_base'
require_relative '../../service_wrappers/pet_service_wrapper'
require_relative '../../service_wrappers/contest_service_wrapper'

require 'contest_evaluators/evaluator_base'
require 'contest_evaluators/strength_evaluator'
require 'contest_evaluators/agility_evaluator'
require 'contest_evaluators/wit_evaluator'
require 'contest_evaluators/senses_evaluator'

class ContestWorker
  include Sidekiq::Worker

  def perform(contest_id)
    contest = get_contest(contest_id)
    petA = get_pet(contest.first_pet_id)
    petB = get_pet(contest.second_pet_id)

    results = get_results_for(contest, petA, petB)

    contest.set_winner(results.winner.id)
    petA.update_experience(results.pet_a_exp_gain)
    petB.update_experience(results.pet_b_exp_gain)
  end

  def pets_svc
    @_pets_svc ||= PetServiceWrapper.new
  end

  def contests_svc
    @_contests_svc ||= ContestServiceWrapper.new
  end

  def get_contest(id)
    contests_svc.get(id)
  end

  def get_pet(id)
    pets_svc.get(id)
  end

  def get_results_for(contest, petA, petB)
    evaluator = evaluator_class_for(contest).new(petA, petB)
    evaluator.evaluate!
    evaluator
  end

  def evaluator_class_for(contest)
    case contest.type
      when 'strength'
        StrengthEvaluator
      when 'agility'
        AgilityEvaluator
      when 'wit'
        WitEvaluator
      when 'senses'
        SensesEvaluator
      else
        raise ArgumentError.new('Unknown evaluator type')
    end
  end
end