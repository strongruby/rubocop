# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::TypeCheck::TypeChecker do
  subject(:cop) { described_class.new }

  before do
    inspect_source(cop, source)
  end

  context 'on an integer literal of the return type' do
    let(:source) do
      ['def foo : Integer',
       '  1',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on an integer literal outside the return type' do
    let(:source) do
      ['def foo : Integer',
       '  "bar"',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Integer, got String.'])
    end
  end

  context 'on a string literal of the return type' do
    let(:source) do
      ['def foo : String',
       '  "bar"',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a string literal outside the return type' do
    let(:source) do
      ['def foo : String',
       '  1',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected String, got Integer.'])
    end
  end

  context 'on a float literal of the return type' do
    let(:source) do
      ['def foo : Float',
       '  0.0',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a float literal outside the return type' do
    let(:source) do
      ['def foo : Float',
       '  1',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Float, got Integer.'])
    end
  end

  context 'on a local literal assignment of the return type' do
    let(:source) do
      ['def foo : Integer',
       '  bar = 1',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a local literal assignment outside the return type' do
    let(:source) do
      ['def foo : Float',
       '  bar = 1',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Float, got Integer.'])
    end
  end

  context 'on an instance literal assignment of the return type' do
    let(:source) do
      ['def foo : Integer',
       '  @bar = 1',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on an instance literal assignment outside the return type' do
    let(:source) do
      ['def foo : Float',
       '  @bar = 1',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Float, got Integer.'])
    end
  end
end
