connection: "ga_generated"

# include: "/datagroups.lkml"

include: "/*/*.view.lkml"
include: "/Google_Analytics/Attribution_Models/*.view.lkml"
include: "/Google_Analytics/Custom_Funnels/*.view.lkml"
include: "/Dashboards/*.dashboard"

datagroup: bqml_datagroup {
  #retrain model every day
  max_cache_age: "1 hour"
  sql_trigger: SELECT CURRENT_DATE() ;;
}
aggregate_awareness: yes



explore: ga_sessions {
  label: "Google Analytics Sessions"
  description: "Explores Google Analytics sessions  data."

  always_filter: {
    filters: {
      field: partition_date
      value: "@{PARTITION_DATE_DEFAULT_EXPLORE_FILTER}"
    }
  }

  # aggregate_table:  {}


  join: hits {
    type: left_outer
    sql: LEFT JOIN UNNEST(${ga_sessions.hits}) AS hits ;;
    relationship: one_to_many
  }

  join: page_funnel {
    type: left_outer
    sql_on: ${page_funnel.event1_hit_id} = ${hits.id} ;;
    relationship: one_to_one
  }

  join: event_action_funnel {
    type: left_outer
    sql_on: ${event_action_funnel.event1_hit_id} = ${hits.id} ;;
    relationship: one_to_one
  }

  join: asset_facts {
    type: left_outer
    sql_on: ${hits.page_path_formatted} = ${asset_facts.page} ;;
    relationship: many_to_one
  }

  join: attribution_model_pdt {
    type: left_outer
    sql_on: ${ga_sessions.id} = ${attribution_model_pdt.id};;
    relationship: one_to_one
  }

  join: custom_dimensions {
    type: left_outer
    sql: LEFT JOIN UNNEST(${hits.custom_dimensions}) AS custom_dimensions ;;
    relationship: one_to_many
  }

  join: custom_variables {
    type: left_outer
    sql: LEFT JOIN UNNEST(${hits.custom_variables}) AS custom_variables ;;
    relationship: one_to_many
  }


  join: page_facts {
    type: left_outer
    sql_on: ${ga_sessions.id} = ${page_facts.session_id}
              AND (${hits.hit_number} BETWEEN ${page_facts.hit_number} AND COALESCE(${page_facts.next_page_hit_number}-1, ${page_facts.hit_number}));;
    relationship: one_to_one
  }

  join: page_flow {
    type: left_outer
    sql_on: ${ga_sessions.id} = ${page_flow.session_id};;
    relationship: one_to_one
  }


  join: time_on_page {
    view_label: "Behavior"
    type: left_outer
    sql_on: ${hits.id} = ${time_on_page.hit_id} ;;
    relationship: one_to_one
  }

}

explore: future_input {
  label: "User Propensity Scores"
  join: future_purchase_prediction {
    type: left_outer
    sql_on: ${future_purchase_prediction.clientId} = ${future_input.clientId} ;;
    relationship: one_to_many
  }
}




named_value_format: hour_format {
  value_format: "[h]:mm:ss"
}
