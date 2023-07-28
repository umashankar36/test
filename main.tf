provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "adf_rg" {
  name     = var.resource_group_name
  location = var.location
}
resource "azurerm_data_factory" "adf" {
  name                = var.adf_name
  resource_group_name = azurerm_resource_group.adf_rg.name
  location            = var.location
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "source" {
  name                = "source-storage"
  data_factory_name   = azurerm_data_factory.adf.name
  resource_group_name = azurerm_resource_group.adf_rg.name
  type                = "AzureBlobStorage"
  type_properties     = jsonencode({
    connectionString = var.source_connection_string
  })
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "destination" {
  name                = "destination-storage"
  data_factory_name   = azurerm_data_factory.adf.name
  resource_group_name = azurerm_resource_group.adf_rg.name
  type                = "AzureBlobStorage"
  type_properties     = jsonencode({
    connectionString = var.destination_connection_string
  })
}

resource "azurerm_data_factory_pipeline" "copy_data" {
  name                = "copy_data_pipeline"
  resource_group_name = azurerm_resource_group.example.name
  data_factory_name   = azurerm_data_factory.example.name

  activities {
    name = "copy_data_activity"
    type = "Copy"

    inputs {
      reference_name = "input_blob"
      type           = "DatasetReference"
    }

    outputs {
      reference_name = "output_blob"
      type           = "DatasetReference"
    }

    type_properties {
      source {
        type             = "BlobSource"
        blob_path_prefix = "inputcontainer/inputblob.csv"
      }

      sink {
        type             = "BlobSink"
        blob_path_prefix = "outputcontainer/outputblob.csv"
      }

      copy_behavior = "PreserveHierarchy"
    }

    policy {
      concurrency    = 1
      execution_order = 0
    }
  }
  
  linked_service_name {
    reference_name = "source_storage"
    type           = "LinkedServiceReference"
  }

  linked_service_name {
    reference_name = "destination_storage"
    type           = "LinkedServiceReference"
  }
}