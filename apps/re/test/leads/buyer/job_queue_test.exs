defmodule Re.Leads.Buyer.JobQueueTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.{
    Leads.Buyer,
    Leads.Buyer.JobQueue,
    Repo
  }

  alias Ecto.Multi

  describe "grupozap_buyer_lead" do
    test "process lead with existing user and listing" do
      %{id: id, uuid: listing_uuid} = insert(:listing)
      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: "11", phone: "999999999", client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(Buyer)
      assert buyer.user_uuid == user_uuid
      assert buyer.listing_uuid == listing_uuid
    end

    test "process lead with nil ddd" do
      %{id: id, uuid: listing_uuid} = insert(:listing)

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: nil, phone: "999999999", client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(Buyer)
      refute buyer.user_uuid
      assert buyer.listing_uuid == listing_uuid
    end

    test "process lead with nil phone" do
      %{id: id, uuid: listing_uuid} = insert(:listing)

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: "11", phone: nil, client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(Buyer)
      refute buyer.user_uuid
      assert buyer.listing_uuid == listing_uuid
    end

    test "process lead with nil ddd and phone" do
      %{id: id, uuid: listing_uuid} = insert(:listing)

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: nil, phone: nil, client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(Buyer)
      refute buyer.user_uuid
      assert buyer.phone_number == "not informed"
      assert buyer.listing_uuid == listing_uuid
    end

    test "process lead with no user" do
      %{id: id, uuid: listing_uuid} = insert(:listing)

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: "11", phone: "999999999", client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(Buyer)
      refute buyer.user_uuid
      assert buyer.listing_uuid == listing_uuid
    end

    test "process lead with no listing" do
      %{id: id} = listing = insert(:listing)
      Repo.delete(listing)
      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: "11", phone: "999999999", client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(Buyer)
      assert buyer.user_uuid == user_uuid
      refute buyer.listing_uuid
    end
  end

  describe "facebook_buyer_lead" do
    test "process lead with existing user and listing" do
      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} = insert(:facebook_buyer_lead, phone_number: "+5511999999999")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "facebook_buyer", "uuid" => uuid})

      assert buyer = Repo.one(Buyer)
      assert buyer.user_uuid == user_uuid
      refute buyer.listing_uuid
    end

    test "process lead with nil phone" do
      %{uuid: uuid} = insert(:facebook_buyer_lead, phone_number: nil)

      assert {:error, :insert_buyer_lead, _, _} =
               JobQueue.perform(Multi.new(), %{"type" => "facebook_buyer", "uuid" => uuid})

      refute Repo.one(Buyer)
    end

    test "process lead with no user" do
      %{uuid: uuid} = insert(:facebook_buyer_lead, phone_number: "+5511999999999")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "facebook_buyer", "uuid" => uuid})

      assert buyer = Repo.one(Buyer)
      refute buyer.user_uuid
    end
  end

  describe "imovelweb_buyer_lead" do
    test "process lead with existing user and listing" do
      %{id: id, uuid: listing_uuid} = insert(:listing)
      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} = insert(:imovelweb_buyer_lead, phone: "011999999999", listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "imovelweb_buyer", "uuid" => uuid})

      assert buyer = Repo.one(Buyer)
      assert buyer.user_uuid == user_uuid
      assert buyer.listing_uuid == listing_uuid
    end

    test "process lead with nil phone" do
      %{id: id} = insert(:listing)

      %{uuid: uuid} = insert(:imovelweb_buyer_lead, phone: nil, listing_id: "#{id}")

      assert {:error, :insert_buyer_lead, _, _} =
               JobQueue.perform(Multi.new(), %{"type" => "imovelweb_buyer", "uuid" => uuid})

      refute Repo.one(Buyer)
    end

    test "process lead with no user" do
      %{id: id, uuid: listing_uuid} = insert(:listing)

      %{uuid: uuid} = insert(:imovelweb_buyer_lead, phone: "011999999999", listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "imovelweb_buyer", "uuid" => uuid})

      assert buyer = Repo.one(Buyer)
      refute buyer.user_uuid
      assert buyer.listing_uuid == listing_uuid
    end

    test "process lead with no listing" do
      %{id: id} = listing = insert(:listing)
      Repo.delete(listing)
      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} = insert(:imovelweb_buyer_lead, phone: "011999999999", listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "imovelweb_buyer", "uuid" => uuid})

      assert buyer = Repo.one(Buyer)
      assert buyer.user_uuid == user_uuid
      refute buyer.listing_uuid
    end
  end
end
