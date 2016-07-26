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

  context 'on a nil literal of the return type' do
    let(:source) do
      ['def foo : NilClass',
       '  nil',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a nil literal outside the return type' do
    let(:source) do
      ['def foo : NilClass',
       '  1',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected NilClass, got Integer.'])
    end
  end

  context 'on a true literal of the return type' do
    let(:source) do
      ['def foo : TrueClass',
       '  true',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a true literal outside the return type' do
    let(:source) do
      ['def foo : TrueClass',
       '  1',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected TrueClass, got Integer.'])
    end
  end

  context 'on a false literal of the return type' do
    let(:source) do
      ['def foo : FalseClass',
       '  false',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a false literal outside the return type' do
    let(:source) do
      ['def foo : FalseClass',
       '  1',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected FalseClass, got Integer.'])
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

  context 'on a class literal assignment of the return type' do
    let(:source) do
      ['def foo : Integer',
       '  @@bar = 1',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a class literal assignment outside the return type' do
    let(:source) do
      ['def foo : Float',
       '  @@bar = 1',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Float, got Integer.'])
    end
  end

  context 'on a global literal assignment of the return type' do
    let(:source) do
      ['def foo : Integer',
       '  $bar = 1',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a global literal assignment outside the return type' do
    let(:source) do
      ['def foo : Float',
       '  $bar = 1',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Float, got Integer.'])
    end
  end

  context 'on an empty method of the return type' do
    let(:source) do
      ['def foo : NilClass',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on an empty method outside the return type' do
    let(:source) do
      ['def foo : Integer',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Integer, got NilClass.'])
    end
  end

  context 'returning a local variable with a value of the return type' do
    let(:source) do
      ['def foo : Integer',
       '  bar = 1',
       '  bar',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'returning a local variable with a value outside the return type' do
    let(:source) do
      ['def foo : Integer',
       '  bar = "baz"',
       '  bar',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Integer, got String.'])
    end
  end

  # TODO: This is a NameError in Ruby.
  context 'returning a local variable undefined in the current context' do
    let(:source) do
      ['def foo : Integer',
       '  bar = 1',
       'end',
       '',
       'def baz : Integer',
       '  bar',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Integer, got nil.'])
    end
  end

  # TODO: This is a NameError in Ruby.
  context 'propagating a local variable undefined in the current context' do
    let(:source) do
      ['def foo : Integer',
       '  bar = baz',
       '  bar',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Integer, got nil.'])
    end
  end

  context 'returning a parameter with a value of the return type' do
    let(:source) do
      ['def foo(bar : Integer) : Integer',
       '  bar',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'returning a parameter with a value outside the return type' do
    let(:source) do
      ['def foo(bar : Integer) : Float',
       '  bar',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Float, got Integer.'])
    end
  end

  context 'returning a conditional with a value of the return type ' \
    'in both branches' do
    let(:source) do
      ['def foo(bar : Integer) : Integer',
       '  if bar > 0',
       '    1',
       '  else',
       '    -1',
       '  end',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'returning a parameter with a value outside the return type ' \
    'in both branches' do
    let(:source) do
      ['def foo(bar : Integer) : Integer',
       '  if bar > 0',
       '    "one"',
       '  else',
       '    "minus one"',
       '  end',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Integer, got String.'])
    end
  end

  context 'returning a single-branch conditional with ' \
    'a nil return type' do
    let(:source) do
      ['def foo(bar : Integer) : NilClass',
       '  if bar > 0',
       '    nil',
       '  end',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'returning a single-branch conditional with ' \
    'other than a nil return type' do
    let(:source) do
      ['def foo(bar : Integer) : Integer',
       '  if bar > 0',
       '    bar',
       '  end',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Integer, got nil.'])
    end
  end
end
