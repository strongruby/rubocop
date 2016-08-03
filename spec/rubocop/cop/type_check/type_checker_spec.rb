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

  context 'on a complex literal of the return type' do
    let(:source) do
      ['def foo : Complex',
       '  2i',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a complex literal outside the return type' do
    let(:source) do
      ['def foo : Complex',
       '  1',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Complex, got Integer.'])
    end
  end

  context 'on a rational literal of the return type' do
    let(:source) do
      ['def foo : Rational',
       '  1r',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a rational literal outside the return type' do
    let(:source) do
      ['def foo : Rational',
       '  1i',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Rational, got Complex.'])
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

  context 'on an array literal of the return type' do
    let(:source) do
      ['def foo : Array',
       '  [1, "b", 3.0]',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on an array literal outside the return type' do
    let(:source) do
      ['def foo : Array',
       '  "1, \'b\', 3.0"',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Array, got String.'])
    end
  end

  context 'on a hash literal of the return type' do
    let(:source) do
      ['def foo : Hash',
       '  {:one => 1, :two => 2}',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a hash literal outside the return type' do
    let(:source) do
      ['def foo : Hash',
       '  [:one, 1, :two, 2]',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Hash, got Array.'])
    end
  end

  context 'on a symbol literal of the return type' do
    let(:source) do
      ['def foo : Symbol',
       '  :bar',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a symbol literal outside the return type' do
    let(:source) do
      ['def foo : Symbol',
       '  "bar"',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Symbol, got String.'])
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

  context 'on a local variable of the return type, ' \
    'freshly assigned in both branches of a conditional' do
    let(:source) do
      ['def foo(bar : Integer) : String',
       '  if bar > 0',
       '    baz = "one"',
       '  else',
       '    baz = "two"',
       '  end',
       '  baz',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a local variable of the return type, ' \
    'previously and partially assigned in a single-branch conditional' do
    let(:source) do
      ['def foo(bar : Integer) : String',
       '  baz = "zero"',
       '  if bar > 0',
       '    baz = "one"',
       '  end',
       '  baz',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  # TODO: How meaningful is this?
  context 'on a local variable of the return type, ' \
    'previously and partially assigned in a single-branch conditional' do
    let(:source) do
      ['def foo(bar : Integer) : String',
       '  if bar > 0',
       '    baz = "one"',
       '  end',
       '  baz = "zero"',
       '  baz',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  # TODO: This could become the common superclass later on.
  context 'on a local variable without typing information, ' \
    'inconsistently assigned in both branches of a conditional' do
    let(:source) do
      ['def foo(bar : Integer) : String',
       '  if bar > 0',
       '    baz = 1',
       '  else',
       '    baz = "two"',
       '  end',
       '  baz',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected String, got nil.'])
    end
  end

  context 'on a local variable without typing information, ' \
    'partially assigned in a single-branch conditional' do
    let(:source) do
      ['def foo(bar : Integer) : String',
       '  if bar > 0',
       '    baz = "one"',
       '  end',
       '  baz',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected String, got nil.'])
    end
  end

  context 'on a local variable without typing information, ' \
    'partially assigned in a single branch of a conditional' do
    let(:source) do
      ['def foo(bar : Integer) : String',
       '  if bar > 0',
       '    baz = "one"',
       '  else',
       '    qux = "two"',
       '  end',
       '  baz',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected String, got nil.'])
    end
  end

  context 'on a local variable of the return type, ' \
    'defined in the condition of an if' do
    let(:source) do
      ['def foo(bar : Integer) : Integer',
       '  if (baz = bar)',
       '  end',
       '  baz',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a local variable of the return type, ' \
    'freshly assigned from a condition variable in both branches' do
    let(:source) do
      ['def foo(bar : Integer) : Integer',
       '  if (baz = bar)',
       '    qux = baz',
       '  else',
       '    qux = baz',
       '  end',
       '  qux',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a new object of the return type' do
    let(:source) do
      ['def foo : Rational',
       '  Rational.new(1, 2)',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a new object in the return type' do
    let(:source) do
      ['def foo : Numeric',
       '  Rational.new(1, 2)',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a new object outside the return type' do
    let(:source) do
      ['def foo : Integer',
       '  Numeric.new',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Integer, got Numeric.'])
    end
  end

  context 'on a local method call of the return type' do
    let(:source) do
      ['def foo : Integer',
       '  bar',
       'end',
       '',
       'def bar : Integer',
       '  1',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a local method call outside the return type' do
    let(:source) do
      ['def foo : Integer',
       '  bar',
       'end',
       '',
       'def bar : String',
       '  "one"',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Integer, got String.'])
    end
  end

  # TODO: An unknown parameterless method is indistinguishable from an undefined
  # local variable, a case already covered. Rename/adjust further errors.

  context 'on a local method call with simple parameters and correct arity' do
    let(:source) do
      ['def foo',
       '  bar(1, 2, 3)',
       'end',
       '',
       'def bar(titi, tata, toto)',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a local method call with simple parameters and incorrect arity' do
    let(:source) do
      ['def foo',
       '  bar(1, 2)',
       'end',
       '',
       'def bar(titi, tata, toto)',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Wrong number of arguments: expected 3, got 2.'])
    end
  end

  context 'on a local method call with a simple parameter ' \
    'of its formal type' do
    let(:source) do
      ['def foo',
       '  bar(1)',
       'end',
       '',
       'def bar(baz : Integer)',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a local method call with a simple parameter ' \
    'outside its formal type' do
    let(:source) do
      ['def foo',
       '  bar(1)',
       'end',
       '',
       'def bar(baz : String)',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad argument type: expected String, got Integer.'])
    end
  end

  context 'on a method declaration with an optional parameter ' \
    'and a default value its formal type' do
    let(:source) do
      ['def foo(bar = 1 : Integer)',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a method declaration with an optional parameter ' \
    'and a default value outside its formal type' do
    let(:source) do
      ['def foo(bar = 1 : Float)',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad default type: expected Float, got Integer.'])
    end
  end

  context 'on a local method call with an optional parameter ' \
    'of the return type' do
    let(:source) do
      ['def foo : Integer',
       '  bar(2)',
       'end',
       '',
       'def bar(baz = 1 : Integer) : Integer',
       '  baz',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a local method call with an optional parameter ' \
    'outside the return type' do
    let(:source) do
      ['def foo',
       '  bar(2.0)',
       'end',
       '',
       'def bar(baz = 1 : Integer)',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad argument type: expected Integer, got Float.'])
    end
  end

  context 'on a local method call with an omitted optional parameter ' \
    'and correct arity' do
    let(:source) do
      ['def foo',
       '  bar',
       'end',
       '',
       'def bar(baz = 1 : Integer)',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a local method call with optional parameters ' \
    'and incorrect arity' do
    let(:source) do
      ['def foo',
       '  bar(1, 2)',
       'end',
       '',
       'def bar(baz = 1)',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Wrong number of arguments: expected 0..1, got 2.'])
    end
  end

  context 'on a method declaration with a single block of consecutive ' \
    'optional parameters' do
    let(:source) do
      ['def foo(titi, tata = 2, toto = 3, tutu)',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  # context 'on a method declaration with nonconsecutive optional parameters' do
  #   let(:source) do
  #     ['def foo(titi = 1, tata, toto = 3)',
  #      'end']
  #   end
  #
  #   it 'registers an offense' do
  #   end
  # end

  context 'on a local method call with or without its optional parameters, ' \
    'given in the correct order' do
    let(:source) do
      ['def foo',
       '  bar(1, Rational.new(4, 1))',
       '  bar(1, 1.4142, Rational.new(4, 1))',
       '  bar(1, 6.022e23, "three", Rational.new(4, 1))',
       'end',
       '',
       'def bar(titi : Integer,',
       '        tata = 2.0 : Float,',
       '        toto = "3" : String,',
       '        tutu : Rational)',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a local method call with or without its optional parameters, ' \
    'given in an incorrect order' do
    let(:source) do
      ['def foo',
       '  bar(1, nil, Rational.new(4, 1))',
       'end',
       '',
       'def bar(titi : Integer,',
       '        tata = 2.0 : Float,',
       '        toto = "3" : String,',
       '        tutu : Rational)',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad argument type: expected Float, got NilClass.'])
    end
  end

  context 'returning a named splat argument with a value ' \
    'of the return type' do
    let(:source) do
      ['def foo(*bar) : Array',
       '  bar',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'returning a named splat argument with a value ' \
    'outside the return type' do
    let(:source) do
      ['def foo(*bar) : Integer',
       '  bar',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad return type: expected Integer, got Array.'])
    end
  end

  context 'on a local method call with a named splat parameter ' \
    'and correct types' do
    let(:source) do
      ['def foo',
       '  bar',
       '  bar(1)',
       '  bar(1, 2, 3)',
       'end',
       '',
       'def bar(*baz : Integer)',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a local method call with a named splat parameter ' \
    'and incorrect types' do
    let(:source) do
      ['def foo',
       '  bar(1, 2.0, 3)',
       'end',
       '',
       'def bar(*baz : Integer)',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Bad argument type: expected Integer, got Float.'])
    end
  end

  context 'on a local method call with a named splat parameter ' \
    'surrounded by normal parameters, with correct types' do
    let(:source) do
      ['def foo',
       '  bar(1.0, "two")',
       '  bar(1.0, 2, 3, 4, "five")',
       'end',
       '',
       'def bar(titi : Float, *tata : Integer, toto : String)',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a local method call with a named splat parameter ' \
    'and incorrect arity' do
    let(:source) do
      ['def foo',
       '  bar(1, 2)',
       'end',
       '',
       'def bar(*titi, tata, toto, tutu)',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Wrong number of arguments: expected 3.., got 2.'])
    end
  end
end
