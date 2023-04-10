# stepfunction-terraform

Creacion de una aws step function mediante terraform.

### Requisitos

En la raiz del proyecto debe ir : 

- Carpeta .aws para incorporar los archivos config y credentials.
- Para el caso de Windows se puede incorporar el ejecutable terraform.exe para realizar los despliegues. 
### Instalación

Para usar el proyecto, confirar las credenciales dentro de .aws y ejecutar el siguiente comando.

```
terraform init
terraform plan -var-file=dev.tfvars
terraform apply
```
En caso de usar el ejeutable en la raiz del proyecto (Windows) realizar lo siguiente
```
.\terraform init
.\terraform plan -var-file=dev.tfvars
.\terraform apply
```

Ejemplo de uso con un json 
```
{
 "process_id": "stg-mst-dmt-mdh-chile-full-prod",
 "toolkit_id": "mdh",
 "airflow_id": "airflow-mdh-cl-mdh-cl-prod",
 "cron_expression": "cron(40 11 * * ? *)",
 "folder_artifacts": "yaml_files/",
 "folder_dmt": "mdh/ventas",
 "folder_mst": "mdh/ventas/tienda-fisica",
 "folder_raw": "raw/mdh_easy",
 "folder_stg": "mdh/datos",
 "mst_dmt_config": "etl_configurations_ventas_prod",
 "process_date": "",
 "process_status": "ENABLED",
 "target_glue_database_dmt": "cl_mdh_dmt_ventas_prod",
 "target_glue_database_mst": "cl_mdh_mst_ventas_prod",
 "target_glue_database_stg": "cl_mdh_stg_prod",
 "target_glue_table_dmt": [
  "mdh_ventas_fact_daily_sales",
  "mdh_ventas_dim_item_current",
  "mdh_ventas_dim_location_current",
  "mdh_ventas_dim_calendar_date"
 ],
 "target_glue_table_mst": [
  "sat_transaction_pos_detail",
  "sat_store_char",
  "hub_customer",
  "hub_store",
  "sat_pos_char",
  "hub_product",
  "link_transaction_pos",
  "link_product_cost",
  "sat_customer_information",
  "sat_product_cost_detail",
  "hub_channel",
  "sat_product_measurement",
  "hub_pos"
 ],
 "target_glue_table_raw": {
  "pos_tables": [
   "prod",
   "enc",
   "impdet",
   "desc",
   "pag",
   "clif",
   "reca"
  ],
  "sap_tables": [
   "MAKT",
   "MARA",
   "MARM",
   "MAST",
   "MAW1",
   "MBEW",
   "MEAN",
   "MVKE",
   "STAS",
   "STKO",
   "STPO",
   "T006A",
   "T001W",
   "TVGRT",
   "TVKMT",
   "WLK1",
   "WRSZ",
   "ZVTAB_TMATER"
  ]
 }
}
```


