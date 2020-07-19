require 'spec_helper'

describe ConventionalChangelog::Generator do
  let(:changelog) { File.open("CHANGELOG.md").read }

  describe "#generate!" do
    before :each do
      FileUtils.rm "CHANGELOG.md", force: true
    end

    it 'runs clean' do
      expect { subject.generate! }.to_not raise_exception
      expect(changelog).to include "support commits without scope"
      expect(changelog).to include "change mocked code to correctly return commits without scope"
    end

    context "with no commits" do
      before :each do
        allow(ConventionalChangelog::Git).to receive(:log).and_return ""
      end

      context "when force is not true" do
        it "creates an empty changelog when a version is set" do
          subject.generate!(version: "0.2.0")
          expect(changelog).to eql ""
        end

        it "creates an empty changelog when a version is not set" do
          subject.generate!
          expect(changelog).to eql ""
        end
      end

      context "when force is true" do
        let(:today) { Date.today.strftime("%Y-%m-%d") }

        it "creates an empty changelog with a heading with today's date when a version is set" do
          subject.generate!(version: "0.2.0", force: true)
          expect(changelog).to eql "<a name=\"0.2.0\"></a>\n### 0.2.0 (#{today})\n\n"
        end

        it "creates an empty changelog with a heading with today's date when a version is not set" do
          subject.generate!(force: true)
          expect(changelog).to eql "<a name=\"#{today}\"></a>\n### #{today}\n\n"
        end
      end
    end

    context "with merge commit" do
      before :each do
        allow(ConventionalChangelog::Git).to receive(:log).and_return log
      end

      context "skip merged commit" do
        let(:log) do <<-LOG
4303fd4/////2015-03-30/////feat(admin): increase reports ranges
430fa51/////2015-03-31/////Merge branch 'develop' into 'master'
          LOG
        end

        it 'does not contain merge commit' do
          subject.generate!
          body = <<-BODY
<a name="2015-03-30"></a>
### 2015-03-30

#### Features

* **admin**
  * increase reports ranges ([4303fd4](/../../commit/4303fd4))

          BODY
          expect(changelog).to eql body
        end
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
          expect(changelog).to eql body
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
          expect(changelog + "\n").to eql body
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
          expect(changelog + "\n").to eql body
        end
      end

      context "with no scope" do
        let(:log) do <<-LOG
4303fd4/////2015-03-30/////feat: increase reports ranges
4303fd5/////2015-03-30/////fix: fix annoying bug
          LOG
        end

        it 'creates changelog without scope' do
          subject.generate!
          body = <<-BODY
<a name="2015-03-30"></a>
### 2015-03-30

#### Features

* increase reports ranges ([4303fd4](/../../commit/4303fd4))

#### Bug Fixes

* fix annoying bug ([4303fd5](/../../commit/4303fd5))

          BODY
          expect(changelog).to eql body
        end
      end

    end

    context "when the tag or date of the previous release cannot be determined from the existing CHANGELOG" do
      context "when the CONVENTIONAL_CHANGELOG_LAST_RELEASE environment variable is not set" do
        it "raises a helpful error" do
          File.write("CHANGELOG.md", "original")
          expect { subject.generate! version: "v2.0.0" }.to raise_error(ConventionalChangelog::LastReleaseNotFound, /Could not determine last tag or release date/)
        end
      end

      context "when the CONVENTIONAL_CHANGELOG_LAST_RELEASE environment variable is set" do
        before do
          allow(ENV).to receive(:[]).with('CONVENTIONAL_CHANGELOG_LAST_RELEASE').and_return('v1.2.3')
          allow(ConventionalChangelog::Git).to receive(:log).and_return log
        end

        let(:log) { "4303fd4/////2015-03-30/////feat: increase reports ranges" }

        it "uses the value of CONVENTIONAL_CHANGELOG_LAST_RELEASE as the last release id" do
          File.write("CHANGELOG.md", "original")
          expect(ConventionalChangelog::Git).to receive(:commits).with(since_version: 'v1.2.3').and_call_original
          subject.generate! version: "v2.0.0"
        end
      end
    end

    context "when an error occurs generating the commit log" do
      before do
        allow_any_instance_of(ConventionalChangelog::Writer).to receive(:append_changes).and_raise("an error")
      end

      it "maintains the original content" do
        File.write("CHANGELOG.md", '<a name="v1.0.0"></a>')
        expect { subject.generate! version: "v2.0.0" }.to raise_error(RuntimeError)
        expect(File.read("CHANGELOG.md")).to eq '<a name="v1.0.0"></a>'
      end
    end

    context "with dry_run == true" do
      before do
        File.write("CHANGELOG.md", '<a name="v1.0.0"></a>')
        allow($stdout).to receive(:puts)
      end

      let(:generate) { subject.generate!(version: "v2.0.0", dry_run: true) }

      it "maintains the original content" do
        expect { generate }.to_not change { File.read("CHANGELOG.md") }
      end

      it "prints the contents to stdout" do
        expect($stdout).to receive(:puts).with(/#### Features/)
        generate
      end

    end

    context "with version_headers: false" do
      before do
        allow($stdout).to receive(:puts)
      end

      context "with a version" do
        let(:generate) { subject.generate!(version: "v2.0.0", dry_run: true, version_headers: false) }

        it "does not include the version headings with a version" do
          expect(generate).to start_with "#### Features"
          expect(generate.scan(/#### Features/).count).to eq 1
          expect(generate.scan(/#### Bug Fixes/).count).to eq 1
        end
      end

      context "without a version" do
        let(:generate) { subject.generate!(dry_run: true, version_headers: false) }

        it "does not include the version headings with a version and does not group the commits" do
          expect(generate).to start_with "#### Features"
          expect(generate.scan(/#### Features/).count).to eq 1
          expect(generate.scan(/#### Bug Fixes/).count).to eq 1
        end
      end
    end

    context "with anchors: false" do
      before do
        allow($stdout).to receive(:puts)
      end

      context "with a version" do
        let(:generate) { subject.generate!(version: "v2.0.0", dry_run: true, anchors: false) }

        it "does not include the anchors" do
          expect(generate).to_not include "<a name"
        end
      end

      context "without a version" do
        let(:generate) { subject.generate!(dry_run: true, anchors: false) }

        it "does not include the version headings with a version and does not group the commits" do
          expect(generate).to_not include "<a name"
        end
      end
    end
  end
end
