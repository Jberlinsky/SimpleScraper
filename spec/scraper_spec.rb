require 'spec_helper'

describe Scraper do
  describe '.is_excluded?' do
    subject { Scraper.is_excluded?(url, exclusions) }
    let(:url) { 'http://www.google.com/' }
    let(:exclusions) { [] }

    context 'when no exclusions are present' do
      it { should be_false }
    end

    context 'when google is excluded' do
      let(:exclusions) { [
        /google/
      ]}

      it { should be_true }
    end

    context 'when another domain is excluded' do
      let(:exclusions) { [
        /aol/
      ]}

      it { should be_false }
    end
  end

  describe '.safely' do
    it 'should not reraise exceptions' do
      unsafe_method = -> { 
        Scraper.safely do
          raise ArgumentError
        end
      }
      expect(unsafe_method).not_to raise_exception
    end

    it 'should execute the original method' do
      $marker.should be_false
      Scraper.safely do
        $marker = true
      end
      $marker.should be_true
    end
  end

  describe '.is_internal_link?' do
    subject { Scraper.is_internal_link?(url) }
    let(:url) { nil }

    context 'when the link is external' do
      let(:url) { "http://www.google.com/image.png" }
      it { should be_false }
    end

    context 'when the link is a reference to a CDN' do
      let(:url) { "//cdn.optimizely.com/js/279869788.js" }
      it { should be_false }
    end

    context 'when the link is a relative local URL' do
      let(:url) { "/asset.jpg" }
      it { should be_true }
    end

    context 'when the link is an absolute local URL' do
      context 'http' do
        let(:url) { 'http://www.joingrouper.com/asset.jpg' }
        it { should be_true }
      end

      context 'https' do
        let(:url) { 'https://www.joingrouper.com/asset.jpg' }
        it { should be_true }
      end
    end

    context 'when the link is an absolute local URL across domains' do
      let(:url) { 'http://joingrouper.com/asset.jpg' }
      it { should be_true }
    end
  end

  describe '.get_source_from_tags' do
    subject { Scraper.get_source_from_tags(nokogiri, tag) }
    let(:nokogiri) { Nokogiri::HTML(html) }
    let(:tag) { nil }
    let(:html) { "" }

    context 'when the tag is not set' do
      it 'should raise an error' do
        expect( -> { subject }).to raise_exception
      end
    end

    context 'when the tag is set' do
      let(:tag) { 'img' }
      context 'when the tags are in the document' do
        let(:html) { "<html><img src='http://www.joingrouper.com/image' /></html>'" }
        it { should == ['http://www.joingrouper.com/image'] }
      end

      context 'when the tags are not in the document' do
        it { should == [] }
      end
    end
  end
end
