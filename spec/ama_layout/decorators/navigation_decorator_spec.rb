describe AmaLayout::NavigationDecorator do
  let(:navigation) { FactoryGirl.build(:navigation) }
  let(:navigation_presenter) { navigation.decorate }
  let(:gatekeeper_site) { "http://auth.waffles.ca" }
  let(:youraccount_site) { "http://youraccount.waffles.ca" }
  let(:insurance_site) { "http://insurance.waffles.ca" }
  let(:membership_site) { "http://membership.waffles.ca" }
  let(:driveredonline_site) { "http://driveredonline.waffles.ca" }
  let(:registries_site) { "http://registries.waffles.ca" }
  let(:automotive_site) { "http://automotive.waffles.ca" }
  let(:travel_site) { "http://travel.waffles.ca" }
  let(:travel_login_url) { "http://travel.waffles.ca/MyAccount" }

  before(:each) do
    allow(Rails.configuration).to receive(:gatekeeper_site).and_return(gatekeeper_site)
    allow(Rails.configuration).to receive(:youraccount_site).and_return(youraccount_site)
    allow(Rails.configuration).to receive(:insurance_site).and_return(insurance_site)
    allow(Rails.configuration).to receive(:membership_site).and_return(membership_site)
    allow(Rails.configuration).to receive(:driveredonline_site).and_return(driveredonline_site)
    allow(Rails.configuration).to receive(:registries_site).and_return(registries_site)
    allow(Rails.configuration).to receive(:automotive_site).and_return(automotive_site)
    allow(Rails.configuration).to receive(:travel_site).and_return(travel_site)
    allow(Rails.configuration).to receive(:travel_login_url).and_return(travel_login_url)
  end

  describe "#display_name_text" do
    let(:user) { OpenStruct.new(email: 'john.doe@test.com') }

    context "name is provided" do
      let(:name) { "John D" }
      let(:nav) { AmaLayout::Navigation.new(user: user, display_name: name).decorate }

      it "has a welcome message" do
        expect(nav.display_name_text).to eq "Welcome, John D"
      end

      context "long name given" do
        let(:name) { "A Really Really Really Really Long Name" }

        it "trucates to a total of 30 characters" do
          expect(nav.display_name_text).to eq "Welcome, #{name.titleize}".truncate(30)
        end
      end
    end

    context "name is not provided" do
      let(:nav) { AmaLayout::Navigation.new(user: user).decorate }

      it "returns the user's email address" do
        expect(nav.display_name_text).to eq user.email
      end

      context "a really long email" do
        let(:user) { OpenStruct.new(email: 'areallyreallyreallylongemail@test.com') }

        it "trucates to a total of 30 characters" do
          expect(nav.display_name_text).to eq user.email.truncate(30)
        end
      end
    end
  end

  describe "#items" do
    before(:each) do
      allow_any_instance_of(AmaLayout::Navigation).to receive(:user).and_return(OpenStruct.new(navigation: "member"))
    end

    it "returns an array of navigation items" do
      expect(navigation_presenter.items).to be_an Array
    end

    it "array contains decorated navigation items" do
      items = navigation_presenter.items
      items.each do |i|
        expect(i).to be_a AmaLayout::NavigationItemDecorator
      end
    end
  end

  describe "#sign_out_link" do
    context "with user" do
      it "returns link" do
        allow_any_instance_of(AmaLayout::Navigation).to receive(:user).and_return(OpenStruct.new(navigation: "member"))
        expect(navigation_presenter.sign_out_link).to include "Sign Out"
      end
    end

    context "without user" do
      it "does not return the link" do
        expect(navigation_presenter.sign_out_link).to eq ""
      end
    end
  end

  describe "#top_nav" do
    context "with items" do
      it "renders the partial" do
        allow_any_instance_of(AmaLayout::Navigation).to receive(:user).and_return(OpenStruct.new(navigation: "member"))
        allow_any_instance_of(AmaLayout::AmaLayoutView).to receive(:render).and_return "render"
        expect(navigation_presenter.top_nav).to eq "render"
      end
    end

    context "without items" do
      it "does not renders the partial" do
        expect(navigation_presenter.top_nav).to eq nil
      end
    end
  end

  describe "#sidebar" do
    context "with items" do
      it "renders the partial" do
        allow_any_instance_of(AmaLayout::Navigation).to receive(:user).and_return(OpenStruct.new(navigation: "member"))
        allow_any_instance_of(AmaLayout::AmaLayoutView).to receive(:render).and_return "render"
        expect(navigation_presenter.sidebar).to eq "render"
      end
    end

    context "without items" do
      it "does not renders the partial" do
        expect(navigation_presenter.sidebar).to eq nil
      end
    end
  end

  context "account toggle" do
    it "in ama_layout it renders a blank partial" do
      allow_any_instance_of(AmaLayout::Navigation).to receive(:user).and_return(OpenStruct.new(navigation: "member"))
      allow_any_instance_of(AmaLayout::AmaLayoutView).to receive(:render).and_return "render"
      expect(navigation_presenter.account_toggle).to eq "render"
    end

    it "in ama_layout it renders a blank partial" do
      allow_any_instance_of(AmaLayout::Navigation).to receive(:user).and_return(OpenStruct.new(navigation: "member"))
      allow_any_instance_of(AmaLayout::AmaLayoutView).to receive(:render).and_return "render"
      expect(navigation_presenter.account_toggle).to eq "render"
    end
  end

  describe "ama layout view" do
    context "needed to allow rendering based on the view main app" do
      it "attaches additional methods to current decorator - draper is capable of the same thing" do
        expect(navigation_presenter.h(Helpers::AttachMethodsSample.new).additional_info).to eq "Bruce Wayne"
      end
    end
  end

  context 'notification center' do
    let(:store) do
      AmaLayout::Notifications::RedisStore.new(
        db: 4,
        namespace: 'test_notifications',
        host: 'localhost'
      )
    end
    let(:notification_set) { AmaLayout::NotificationSet.new(store, 1) }
    let(:user) { OpenStruct.new(navigation: 'member', notifications: notification_set) }
    let(:navigation) { FactoryGirl.build :navigation, user: user }
    subject { described_class.new(navigation) }

    around(:each) do |example|
      Timecop.freeze(Time.zone.local(2017, 6, 19)) do
        store.clear
        example.run
        store.clear
      end
    end

    describe '#notification_icon' do
      it 'renders the content to the page' do
        expect(subject.notification_icon).to include('data-notifications-toggle')
      end
    end

    describe '#mobile_notification_icon' do
      it 'renders the content to the page' do
        expect(subject.mobile_notification_icon).to include('fa-bell')
      end
    end

    describe '#notification_badge' do
      context 'with 1 active notification' do
        before(:each) do
          user.notifications.create(
            type: :warning,
            header: 'test',
            content: 'test'
          )
        end

        it 'returns a div with the count of active notifications' do
          expect(subject.notification_badge).to include('div')
          expect(subject.notification_badge).to include('1')
        end
      end

      context 'with only inactive notifications' do
        before(:each) do
          user.notifications.create(
            type: :warning,
            header: 'test',
            content: 'test'
          )
          user.notifications.first.dismiss!
          user.notifications.save
        end

        it 'does not return the badge markup' do
          expect(subject.notification_badge).to be nil
        end
      end

      context 'with only active and inactive notifications' do
        before(:each) do
          user.notifications.create(
            type: :warning,
            header: 'test',
            content: 'test'
          )
          2.times do |i|
            user.notifications.create(
              type: :notice,
              header: i,
              content: i
            )
          end
          user.notifications.first.dismiss!
          user.notifications.save
        end

        it 'returns a div with the count of active notifications' do
          expect(subject.notification_badge).to include('div')
          expect(subject.notification_badge).to include('2')
        end
      end
    end

    describe '#notification_sidebar' do
      before(:each) do
        user.notifications.create(
          type: :warning,
          header: 'decorated_notification',
          content: 'decorated_notification'
        )
      end

      it 'renders content to the page' do
        expect(subject.notification_sidebar).to include('decorated_notification')
      end
    end

    describe '#notifications_heading' do
      context 'when notifications are present' do
        before(:each) do
          user.notifications.create(
            type: :warning,
            header: 'test',
            content: 'test'
          )
        end

        it 'returns the correct heading' do
          expect(subject.notifications_heading).to include('Most Recent Notifications')
        end
      end

      context 'when notifications are not present' do
        it 'returns the correct heading' do
          expect(subject.notifications_heading).to include('No Recent Notifications')
        end

        it 'italicizes the message' do
          expect(subject.notifications_heading).to include('italic')
        end
      end
    end
  end
end
