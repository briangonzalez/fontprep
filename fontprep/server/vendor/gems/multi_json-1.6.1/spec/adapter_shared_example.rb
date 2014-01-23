# encoding: UTF-8

shared_examples_for 'an adapter' do |adapter|

  before do
    begin
      MultiJson.use adapter
    rescue LoadError
      pending "Adapter #{adapter} couldn't be loaded (not installed?)"
    end
  end

  describe '.dump' do
    it 'writes decodable JSON' do
      [
        {'abc' => 'def'},
        [1, 2, 3, '4', true, false, nil]
      ].each do |example|
        expect(MultiJson.load(MultiJson.dump(example))).to eq example
      end
    end

    unless 'json_pure' == adapter || 'json_gem' == adapter
      it 'dumps time in correct format' do
        time = Time.at(1355218745).utc

        # time does not respond to to_json method
        class << time
          undef_method :to_json
        end

        dumped_json = MultiJson.dump(time)
        expected = if RUBY_VERSION > '1.9'
          '2012-12-11 09:39:05 UTC'
        else
          'Tue Dec 11 09:39:05 UTC 2012'
        end
        expect(MultiJson.load(dumped_json)).to eq expected
      end
    end

    it 'dumps symbol and fixnum keys as strings' do
      [
        [
          {:foo => {:bar => 'baz'}},
          {'foo' => {'bar' => 'baz'}},
        ],
        [
          [{:foo => {:bar => 'baz'}}],
          [{'foo' => {'bar' => 'baz'}}],
        ],
        [
          {:foo => [{:bar => 'baz'}]},
          {'foo' => [{'bar' => 'baz'}]},
        ],
        [
          {1 => {2 => {3 => 'bar'}}},
          {'1' => {'2' => {'3' => 'bar'}}}
        ]
      ].each do |example, expected|
        dumped_json = MultiJson.dump(example)
        expect(MultiJson.load(dumped_json)).to eq expected
      end
    end

    it 'dumps rootless JSON' do
      expect(MultiJson.dump('random rootless string')).to eq '"random rootless string"'
      expect(MultiJson.dump(123)).to eq '123'
    end

    it 'passes options to the adapter' do
      MultiJson.adapter.should_receive(:dump).with('foo', {:bar => :baz})
      MultiJson.dump('foo', :bar => :baz)
    end

    # This behavior is currently not supported by gson.rb
    # See discussion at https://github.com/intridea/multi_json/pull/71
    unless adapter == 'gson'
      it 'dumps custom objects that implement to_json' do
        klass = Class.new do
          def to_json(*)
            '"foobar"'
          end
        end
        expect(MultiJson.dump(klass.new)).to eq '"foobar"'
      end
    end

    it 'allows to dump JSON values' do
      expect(MultiJson.dump(42)).to eq '42'
    end

    it 'allows to dump JSON with UTF-8 characters' do
      expect(MultiJson.dump({'color' => 'żółć'})).to eq('{"color":"żółć"}')
    end
  end

  describe '.load' do
    it 'properly loads valid JSON' do
      expect(MultiJson.load('{"abc":"def"}')).to eq({'abc' => 'def'})
    end

    it 'raises MultiJson::LoadError on invalid JSON' do
      expect{MultiJson.load('{"abc"}')}.to raise_error(MultiJson::LoadError)
    end

    it 'raises MultiJson::LoadError with data on invalid JSON' do
      data = '{invalid}'
      begin
        MultiJson.load(data)
      rescue MultiJson::LoadError => le
        expect(le.data).to eq data
      end
    end

    it 'catches MultiJson::DecodeError for legacy support' do
      data = '{invalid}'
      begin
        MultiJson.load(data)
      rescue MultiJson::DecodeError => de
        expect(de.data).to eq data
      end
    end

    it 'stringifys symbol keys when encoding' do
      dumped_json = MultiJson.dump(:a => 1, :b => {:c => 2})
      expect(MultiJson.load(dumped_json)).to eq({'a' => 1, 'b' => {'c' => 2}})
    end

    it 'properly loads valid JSON in StringIOs' do
      json = StringIO.new('{"abc":"def"}')
      expect(MultiJson.load(json)).to eq({'abc' => 'def'})
    end

    it 'allows for symbolization of keys' do
      [
        [
          '{"abc":{"def":"hgi"}}',
          {:abc => {:def => 'hgi'}},
        ],
        [
          '[{"abc":{"def":"hgi"}}]',
          [{:abc => {:def => 'hgi'}}],
        ],
        [
          '{"abc":[{"def":"hgi"}]}',
          {:abc => [{:def => 'hgi'}]},
        ],
      ].each do |example, expected|
        expect(MultiJson.load(example, :symbolize_keys => true)).to eq expected
      end
    end

    it 'allows to load JSON values' do
      expect(MultiJson.load('42')).to eq 42
    end

    it 'allows to load JSON with UTF-8 characters' do
      expect(MultiJson.load('{"color":"żółć"}')).to eq({'color' => 'żółć'})
    end
  end
end
