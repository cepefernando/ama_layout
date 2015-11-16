describe AmaLayout::Navigation do
  let(:gatekeeper_site) { "http://auth.waffles.ca" }
  let(:youraccount_site) { "http://youraccount.waffles.ca" }
  let(:insurance_site) { "http://insurance.waffles.ca" }
  let(:membership_site) { "http://membership.waffles.ca" }
  let(:driveredonline_site) { "http://driveredonline.waffles.ca" }

  before(:each) do
    allow(Rails.configuration).to receive(:gatekeeper_site).and_return(gatekeeper_site)
    allow(Rails.configuration).to receive(:youraccount_site).and_return(youraccount_site)
    allow(Rails.configuration).to receive(:insurance_site).and_return(insurance_site)
    allow(Rails.configuration).to receive(:membership_site).and_return(membership_site)
    allow(Rails.configuration).to receive(:driveredonline_site).and_return(driveredonline_site)
  end

  describe "#items" do
    context "member" do
      before(:each) do
        allow_any_instance_of(AmaLayout::Navigation).to receive(:user).and_return(OpenStruct.new(navigation: "member"))
      end

      it "returns member navigation items" do
        expect(subject.items[0].text).to eq "My Account Overview"
        expect(subject.items[0].alt).to eq "Back to my dashboard"
        expect(subject.items[0].link).to eq "#{gatekeeper_site}/"
        expect(subject.items[0].icon).to eq "fa-tachometer"

        expect(subject.items[1].text).to eq "My Membership"
        expect(subject.items[1].link).to eq "#"
        expect(subject.items[1].icon).to eq "fa-credit-card"

        expect(subject.items[2].text).to eq "My Driver Education"
        expect(subject.items[2].link).to eq "#{driveredonline_site}"
        expect(subject.items[2].icon).to eq "fa-car"

        expect(subject.items[3].text).to eq "My Reward Dollars"
        expect(subject.items[3].link).to eq "#{youraccount_site}/reward_dollars"
        expect(subject.items[3].icon).to eq "fa-usd"

        expect(subject.items[4].text).to eq "Reload Esso Gift Cards"
        expect(subject.items[4].link).to eq "#{membership_site}/reward_cards"
        expect(subject.items[4].icon).to eq "fa-arrow-up"

        expect(subject.items[5].text).to eq "My Account Settings"
        expect(subject.items[5].link).to eq "#"
        expect(subject.items[5].icon).to eq "fa-cogs"
      end
    end

    context "non-member" do
      before(:each) do
        allow_any_instance_of(AmaLayout::Navigation).to receive(:user).and_return(OpenStruct.new(navigation: "non-member"))
      end

      it "returns non-member navigation items" do
        expect(subject.items[0].text).to eq "Account Dashboard"
        expect(subject.items[0].alt).to eq "Back to my dashboard"
        expect(subject.items[0].link).to eq "#{gatekeeper_site}/"
        expect(subject.items[0].icon).to eq "fa-tachometer"

        expect(subject.items[1].text).to eq "Join AMA"
        expect(subject.items[1].alt).to eq "Join AMA"
        expect(subject.items[1].link).to eq membership_site
        expect(subject.items[1].icon).to eq "fa-credit-card"

        expect(subject.items[2].text).to eq "Driver Education"
        expect(subject.items[2].link).to eq "#{driveredonline_site}"
        expect(subject.items[2].icon).to eq "fa-car"

        expect(subject.items[3].text).to eq "Change Email/Password"
        expect(subject.items[3].link).to eq "#{gatekeeper_site}/user/edit"
        expect(subject.items[3].icon).to eq "fa-cogs"
      end
    end

    context "member-in-renewal" do
      before(:each) do
        allow_any_instance_of(AmaLayout::Navigation).to receive(:user).and_return(OpenStruct.new(navigation: "member-in-renewal"))
      end

      it "returns member-in-renewal navigation items" do
        expect(subject.items[0].text).to eq "Account Dashboard"
        expect(subject.items[0].alt).to eq "Back to my dashboard"
        expect(subject.items[0].link).to eq "#{gatekeeper_site}/"
        expect(subject.items[0].icon).to eq "fa-tachometer"

        expect(subject.items[1].text).to eq "Renew"
        expect(subject.items[1].link).to eq "#{youraccount_site}/renew"
        expect(subject.items[1].icon).to eq "fa-credit-card"

        expect(subject.items[2].text).to eq "Driver Education"
        expect(subject.items[2].link).to eq "#{driveredonline_site}"
        expect(subject.items[2].icon).to eq "fa-car"
      end
    end

    context "member-in-renewal-late" do
      before(:each) do
        allow_any_instance_of(AmaLayout::Navigation).to receive(:user).and_return(OpenStruct.new(navigation: "member-in-renewal-late"))
      end

      it "returns member-in-renewal-late navigation items" do
        expect(subject.items[0].text).to eq "Account Dashboard"
        expect(subject.items[0].alt).to eq "Back to my dashboard"
        expect(subject.items[0].link).to eq "#{gatekeeper_site}/"
        expect(subject.items[0].icon).to eq "fa-tachometer"

        expect(subject.items[1].text).to eq "Driver Education"
        expect(subject.items[1].link).to eq driveredonline_site
        expect(subject.items[1].icon).to eq "fa-car"
      end
    end
  end
end
