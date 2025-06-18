import Service, { service } from "@ember/service";
import discourseLater from "discourse/lib/later";
import CollectionForm from "../components/modals/collection-form";

/**
 * Standalone service for handling edit modals.
 * This is to preserve the modal state outside of any components.
 */
export default class EditCollection extends Service {
  @service modal;

  manageCollection(topic, collection) {
    this.modal.close();
    discourseLater(() => {
      this.modal.show(CollectionForm, {
        model: {
          topic,
          collection,
          isSubcollection: false,
        },
      });
    });
  }

  manageSubcollection(topic, collection) {
    this.modal.close();
    discourseLater(() => {
      this.modal.show(CollectionForm, {
        model: {
          topic,
          collection,
          isSubcollection: true,
        },
      });
    });
  }
}
