require 'spec_helper'

describe ConventionalChangelog::Generator do
  describe "#generate!" do
    before :each do
      FileUtils.rm "CHANGELOG.md", force: true
    end

    it 'runs clean' do
      expect { subject.generate! }.to_not raise_exception  
    end

    context "with no commits" do
      before :each do
        allow(ConventionalChangelog::Git).to receive(:log).and_return ""
      end

      it 'creates an empty changelog when no commits' do
        subject.generate!
        expect(File.open("CHANGELOG.md").read).to eql "\n"
      end
    end

    context "with multiple commits" do
      before :each do
        allow(ConventionalChangelog::Git).to receive(:log).and_return log
      end

      context "without a version param" do
        let(:log) do <<-LOG
4303fd4/////2015-03-30/////feat(admin): increase reports ranges
4303fd5/////2015-03-30/////fix(api): fix annoying bug
4303fd6/////2015-03-28/////feat(api): add cool service
4303fd7/////2015-03-28/////feat(api): add cool feature
4303fd8/////2015-03-28/////feat(admin): add page to manage users
          LOG
        end

        it 'parses simple lines into dates' do
          subject.generate!
          body = <<-BODY
<a name="2015-03-30"></a>
### 2015-03-30


#### Features

* **admin**
  * increase reports ranges ([4303fd4](/../../commit/4303fd4))


#### Bug Fixes

* **api**
  * fix annoying bug ([4303fd5](/../../commit/4303fd5))


<a name="2015-03-28"></a>
### 2015-03-28


#### Features

* **api**
  * add cool service ([4303fd6](/../../commit/4303fd6))
  * add cool feature ([4303fd7](/../../commit/4303fd7))

* **admin**
  * add page to manage users ([4303fd8](/../../commit/4303fd8))



          BODY
          expect(File.open("CHANGELOG.md").read).to eql body
        end

        it 'preserves previous changes' do
          previous_body = <<-BODY
<a name="2015-03-28"></a>
### 2015-03-28


#### Features

* **api**
  * add cool service modified (4303fd6)
  * add cool feature (4303fd7)

* **admin**
  * add page to manage users (4303fd8)
          BODY
          File.open("CHANGELOG.md", "w") { |f| f.puts previous_body }
          body = <<-BODY
<a name="2015-03-30"></a>
### 2015-03-30


#### Features

* **admin**
  * increase reports ranges ([4303fd4](/../../commit/4303fd4))


#### Bug Fixes

* **api**
  * fix annoying bug ([4303fd5](/../../commit/4303fd5))


#{previous_body}
          BODY
          subject.generate!
          expect(File.open("CHANGELOG.md").read + "\n").to eql body
        end
      end

      context "with a version param" do
        let(:log) do <<-LOG
4303fd4/////2015-03-30/////feat(admin): increase reports ranges
4303fd5/////2015-03-29/////fix(api): fix annoying bug
          LOG
        end

        it 'preserves previous changes' do
          previous_body = <<-BODY
<a name="0.1.0"></a>
### 0.1.0 (2015-03-28)


#### Features

* **api**
  * add cool service (4303fd6)
  * add cool feature (4303fd7)

* **admin**
  * add page to manage users (4303fd8)
          BODY
          File.open("CHANGELOG.md", "w") { |f| f.puts previous_body }
          body = <<-BODY
<a name="0.2.0"></a>
### 0.2.0 (2015-03-30)


#### Features

* **admin**
  * increase reports ranges ([4303fd4](/../../commit/4303fd4))


#### Bug Fixes

* **api**
  * fix annoying bug ([4303fd5](/../../commit/4303fd5))


#{previous_body}
          BODY
          subject.generate! version: '0.2.0'
          expect(File.open("CHANGELOG.md").read + "\n").to eql body
        end
      end
    end
  end
end
