DROP PROGRAM phsa_upt_person_flag GO
CREATE PROGRAM phsa_upt_person_flag
 DECLARE testind = i1 WITH constant (false )
 DECLARE race_cs = i4 WITH constant (282 ) ,protect
 DECLARE isolation_cs = i4 WITH constant (70 ) ,protect
 DECLARE disease_alert_cs = i4 WITH constant (19349 ) ,protect
 DECLARE process_alert_cs = i4 WITH constant (19350 ) ,protect
 DECLARE process_multi_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,process_alert_cs ,
   "MULTISELECT" ) ) ,protect
 DECLARE disease_multi_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,disease_alert_cs ,
   "MULTISELECT" ) ) ,protect
 DECLARE race_multi_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,race_cs ,"MULTIPLE" ) ) ,
 protect
 DECLARE pm_hist_tracking_id = f8 WITH noconstant (0.0 ) ,protect
 DECLARE pm_trans_id = f8 WITH noconstant (0.0 ) ,protect
 DECLARE i = i4 WITH protect
 EXECUTE phsa_lib_logging
 EXECUTE phsa_lib_common
 EXECUTE pf_error_check
 CALL echo ("BEGIN INCLUDE - phsa_lib_status.inc" )
 IF (NOT (validate (reply ) ) )
  FREE RECORD reply
  RECORD reply (
    1 status_ind = i2
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH persistscript
 ENDIF
 EXECUTE phsa_lib_status WITH replace ("REPLY" ,reply )
 DECLARE err_stat = i2 WITH constant (defstat ("F" ,0 ,"GENERAL ERROR" ) )
 DECLARE success_stat = i2 WITH constant (defstat ("S" ,1 ,"Success" ,true ) )
 DECLARE zero_stat = i2 WITH constant (defstat ("Z" ,1 ,"No records qualified" ,true ) )
 CALL setstat (err_stat )
 CALL echo ("END INCLUDE - phsa_lib_status.inc" )
 DECLARE stat_succ = i2 WITH constant (defstat ("S" ,1 ,"Success" ) ) ,protect
 DECLARE stat_none = i2 WITH constant (defstat ("Z" ,2 ,"No changes to the person are required" ) ) ,
 protect
 DECLARE stat_err = i2 WITH constant (defstat ("F" ,0 ,"ERROR" ) ) ,protect
 CALL echorec (request )
 IF (((NOT (validate (request->person_id ) ) ) OR ((request->person_id <= 0.0 ) )) )
  CALL setstat (stat_err ,"No person_id in the request structure" )
  GO TO exit_script
 ENDIF
 IF (validate (request->encntr_id ) )
  IF ((((request->isolation_flag.flag_cd > 0.0 ) ) OR ((request->isolation_flag.remove_ind > 0 ) ))
  AND (request->encntr_id <= 0.0 ) )
   CALL setstat (stat_err ,"Request contains change to isolation_cd but no encntr_id is provided" )
   GO TO exit_script
  ENDIF
 ELSE
  CALL setstat (stat_err ,"Invalid request structure. Encntr_id field is missing" )
  GO TO exit_script
 ENDIF
 IF ((- (1.0 ) IN (race_multi_cd ,
 disease_multi_cd ,
 process_multi_cd ) ) )
  CALL setstat (stat_err ,"Error getting code values" )
  GO TO exit_script
 ENDIF
 FREE SET req_101101
 RECORD req_101101 (
   1 mode = i2
   1 person_qual = i4
   1 esi_ensure_type = c3
   1 person [* ]
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 action_type = c3
     2 new_person = c1
     2 person_id = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_prsnl_id = f8
     2 active_status_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 person_type_cd = f8
     2 name_last_key = c100
     2 name_first_key = c100
     2 name_full_formatted = c100
     2 name_first_phonetic = c8
     2 name_last_phonetic = c8
     2 autopsy_cd = f8
     2 birth_dt_cd = f8
     2 birth_dt_tm = dq8
     2 conception_dt_tm = dq8
     2 cause_of_death = c100
     2 cause_of_death_cd = f8
     2 deceased_cd = f8
     2 deceased_dt_tm = dq8
     2 ethnic_grp_cd = f8
     2 language_cd = f8
     2 marital_type_cd = f8
     2 purge_option_cd = f8
     2 race_cd = f8
     2 religion_cd = f8
     2 sex_cd = f8
     2 sex_age_change_ind_ind = i2
     2 sex_age_change_ind = i2
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 language_dialect_cd = f8
     2 name_last = c200
     2 name_first = c200
     2 name_phonetic = c8
     2 last_encntr_dt_tm = dq8
     2 species_cd = f8
     2 confid_level_cd = f8
     2 vip_cd = f8
     2 name_first_synonym_id = f8
     2 citizenship_cd = f8
     2 vet_military_status_cd = f8
     2 mother_maiden_name = c100
     2 nationality_cd = f8
     2 ft_entity_name = c32
     2 ft_entity_id = f8
     2 name_middle_key = c100
     2 name_middle = c200
     2 military_rank_cd = f8
     2 military_service_cd = f8
     2 military_base_location = c100
     2 deceased_source_cd = f8
     2 updt_cnt = i4
     2 birth_tz = i4
     2 birth_tz_disp = vc
     2 birth_prec_flag = i2
     2 deceased_id_method_cd = f8
     2 logical_domain_id = f8
     2 logical_domain_id_ind = i2
     2 person_status_cd = f8
     2 race_list_ind = i2
     2 race_list [* ]
       3 value_cd = f8
     2 pre_person_id = f8
     2 ethnic_grp_list_ind = i2
     2 ethnic_grp_list [* ]
       3 value_cd = f8
     2 emancipation_dt_tm = dq8
     2 deceased_tz = i4
     2 deceased_dt_tm_prec_flag = i2
 ) WITH protect
 FREE SET req_101104
 RECORD req_101104 (
   1 person_patient_qual = i4
   1 esi_ensure_type = c3
   1 mode = i2
   1 person_patient [* ]
     2 action_type = c3
     2 new_person = c1
     2 person_id = f8
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 adopted_cd = f8
     2 bad_debt_cd = f8
     2 baptised_cd = f8
     2 birth_multiple_cd = f8
     2 birth_order_ind = i2
     2 birth_order = i4
     2 birth_length_ind = i4
     2 birth_length = f8
     2 birth_length_units_cd = f8
     2 birth_name = c100
     2 birth_weight_ind = i4
     2 birth_weight = f8
     2 birth_weight_units_cd = f8
     2 church_cd = f8
     2 credit_hrs_taking_ind = i2
     2 credit_hrs_taking = i4
     2 cumm_leave_days_ind = i2
     2 cumm_leave_days = i4
     2 current_balance_ind = i4
     2 current_balance = f8
     2 current_grade_ind = i2
     2 current_grade = i4
     2 custody_cd = f8
     2 degree_complete_cd = f8
     2 diet_type_cd = f8
     2 family_income_ind = i4
     2 family_income = f8
     2 family_size_ind = i2
     2 family_size = i4
     2 highest_grade_complete_cd = f8
     2 immun_on_file_cd = f8
     2 interp_required_cd = f8
     2 interp_type_cd = f8
     2 microfilm_cd = f8
     2 nbr_of_brothers_ind = i2
     2 nbr_of_brothers = i4
     2 nbr_of_sisters_ind = i2
     2 nbr_of_sisters = i4
     2 organ_donor_cd = f8
     2 parent_marital_status_cd = f8
     2 smokes_cd = f8
     2 tumor_registry_cd = f8
     2 last_bill_dt_tm = dq8
     2 last_bind_dt_tm = dq8
     2 last_discharge_dt_tm = dq8
     2 last_event_updt_dt_tm = dq8
     2 last_payment_dt_tm = dq8
     2 last_atd_activity_dt_tm = dq8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 student_cd = f8
     2 living_dependency_cd = f8
     2 living_arrangement_cd = f8
     2 living_will_cd = f8
     2 nbr_of_pregnancies_ind = i2
     2 nbr_of_pregnancies = i4
     2 last_trauma_dt_tm = dq8
     2 mother_identifier = c100
     2 mother_identifier_cd = f8
     2 disease_alert_cd = f8
     2 disease_alert_list_ind = i2
     2 disease_alert [* ]
       3 value_cd = f8
     2 process_alert_cd = f8
     2 process_alert_list_ind = i2
     2 process_alert [* ]
       3 value_cd = f8
     2 updt_cnt = i4
     2 contact_list_cd = f8
     2 gest_age_at_birth = i4
     2 gest_age_method_cd = f8
     2 contact_method_cd = f8
     2 contact_time = c255
     2 callback_consent_cd = f8
     2 written_format_cd = f8
     2 birth_order_cd = f8
     2 prev_contact_ind = i2
     2 source_sync_level_flag = i2
     2 iqh_participant_cd = f8
     2 source_version_number = c255
     2 source_last_sync_dt_tm = dq8
     2 family_nbr_of_minors_cnt = i4
     2 fin_statement_expire_dt_tm = dq8
     2 fin_statement_verified_dt_tm = dq8
     2 fam_income_source_list_ind = i2
     2 fam_income_source [* ]
       3 value_cd = f8
     2 health_info_access_offered_cd = f8
     2 birth_sex_cd = f8
     2 health_app_access_offered_cd = f8
     2 financial_risk_level_cd = f8
 ) WITH protect
 FREE SET req_101301
 RECORD req_101301 (
   1 encounter_qual = i4
   1 esi_ensure_type = c3
   1 mode = i2
   1 encounter [* ]
     2 mental_health_cd = f8
     2 mental_health_dt_tm = dq8
     2 action_type = c3
     2 new_person = c1
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 transaction_reason_cd = f8
     2 encntr_id = f8
     2 person_id = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 encntr_class_cd = f8
     2 encntr_type_cd = f8
     2 encntr_type_class_cd = f8
     2 encntr_status_cd = f8
     2 pre_reg_dt_tm = dq8
     2 pre_reg_prsnl_id = f8
     2 reg_dt_tm = dq8
     2 reg_prsnl_id = f8
     2 est_arrive_dt_tm = dq8
     2 est_depart_dt_tm = dq8
     2 arrive_dt_tm = dq8
     2 depart_dt_tm = dq8
     2 admit_type_cd = f8
     2 admit_src_cd = f8
     2 admit_mode_cd = f8
     2 admit_with_medication_cd = f8
     2 referring_comment = c100
     2 disch_disposition_cd = f8
     2 disch_to_loctn_cd = f8
     2 preadmit_nbr = c100
     2 preadmit_testing_cd = f8
     2 preadmit_testing_list_ind = i2
     2 preadmit_testing [* ]
       3 value_cd = f8
     2 readmit_cd = f8
     2 accommodation_cd = f8
     2 accommodation_request_cd = f8
     2 alt_result_dest_cd = f8
     2 ambulatory_cond_cd = f8
     2 courtesy_cd = f8
     2 diet_type_cd = f8
     2 isolation_cd = f8
     2 med_service_cd = f8
     2 result_dest_cd = f8
     2 confid_level_cd = f8
     2 vip_cd = f8
     2 name_last_key = c200
     2 name_first_key = c200
     2 name_full_formatted = c200
     2 name_last = c200
     2 name_first = c200
     2 name_phonetic = c200
     2 sex_cd = f8
     2 birth_dt_cd = f8
     2 birth_dt_tm = dq8
     2 species_cd = f8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 location_cd = f8
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
     2 disch_dt_tm = dq8
     2 guarantor_type_cd = f8
     2 loc_temp_cd = f8
     2 organization_id = f8
     2 esiorgalias [* ]
       3 alias_pool_cd = f8
       3 alias_type_cd = f8
       3 alias = c200
     2 def_organization_id = f8
     2 reason_for_visit = c255
     2 encntr_financial_id = f8
     2 name_first_synonym_id = f8
     2 financial_class_cd = f8
     2 bbd_procedure_cd = f8
     2 info_given_by = c100
     2 safekeeping_cd = f8
     2 trauma_cd = f8
     2 triage_cd = f8
     2 triage_dt_tm = dq8
     2 visitor_status_cd = f8
     2 valuables_cd = f8
     2 valuables_list_ind = i2
     2 valuables [* ]
       3 value_cd = f8
     2 security_access_cd = f8
     2 refer_facility_cd = f8
     2 trauma_dt_tm = dq8
     2 accomp_by_cd = f8
     2 accommodation_reason_cd = f8
     2 program_service_cd = f8
     2 specialty_unit_cd = f8
     2 updt_cnt = i4
     2 chart_complete_dt_tm = dq8
     2 encntr_complete_dt_tm = dq8
     2 zero_balance_dt_tm = dq8
     2 archive_dt_tm_est = dq8
     2 archive_dt_tm_act = dq8
     2 purge_dt_tm_est = dq8
     2 purge_dt_tm_act = dq8
     2 pa_current_status_dt_tm = dq8
     2 pa_current_status_cd = f8
     2 parent_ret_criteria_id = f8
     2 service_category_cd = f8
     2 old_transaction_dt_tm = dq8
     2 encntr_fin_hist_type_cd = f8
     2 est_length_of_stay = i4
     2 contract_status_cd = f8
     2 attend_prsnl_id = f8
     2 assign_to_loc_dt_tm = dq8
     2 alt_lvl_care_cd = f8
     2 alt_lvl_care_dt_tm = dq8
     2 alc_reason_cd = f8
     2 alc_decomp_dt_tm = dq8
     2 region_cd = f8
     2 sitter_required_cd = f8
     2 doc_rcvd_dt_tm = dq8
     2 referral_rcvd_dt_tm = dq8
     2 place_auth_prsnl_id = f8
     2 patient_classification_cd = f8
     2 mental_category_cd = f8
     2 psychiatric_status_cd = f8
     2 inpatient_admit_dt_tm = dq8
     2 result_acc_dt_tm = dq8
     2 pregnancy_status_cd = f8
     2 expected_delivery_dt_tm = dq8
     2 last_menstrual_period_dt_tm = dq8
     2 onset_dt_tm = dq8
     2 level_of_service_cd = f8
     2 abn_status_cd = f8
     2 place_of_svc_org_id = f8
     2 place_of_svc_type_cd = f8
     2 place_of_svc_admit_dt_tm = dq8
     2 est_financial_resp_amt = f8
     2 treatment_phase_cd = f8
     2 incident_cd = f8
     2 client_organization_id = f8
     2 person_plan_profile_type_cd = f8
   1 encntrlochistoverride = i2
 ) WITH protect
 FREE SET req_101131
 RECORD req_101131 (
   1 pm_hist_tracking_id = f8
   1 transaction_id = f8
   1 transaction = vc
   1 transaction_dt_tm = dq8
   1 hl7_event = vc
   1 person_id = f8
   1 encntr_id = f8
   1 contributor_system_cd = f8
   1 transaction_reason = vc
   1 transaction_reason_cd = f8
   1 task_number = i4
   1 trans
     2 transaction_id = f8
     2 activity_dt_tm = dq8
     2 transaction = c4
     2 n_person_id = f8
     2 o_person_id = f8
     2 n_encntr_id = f8
     2 o_encntr_id = f8
     2 n_encntr_fin_id = f8
     2 o_encntr_fin_id = f8
     2 n_mrn = c20
     2 o_mrn = c20
     2 n_fin_nbr = c20
     2 o_fin_nbr = c20
     2 n_name_last = c20
     2 o_name_last = c20
     2 n_name_first = c20
     2 o_name_first = c20
     2 n_name_middle = c20
     2 o_name_middle = c20
     2 n_name_formatted = c30
     2 o_name_formatted = c30
     2 n_birth_dt_cd = f8
     2 o_birth_dt_cd = f8
     2 n_birth_dt_tm = dq8
     2 o_birth_dt_tm = dq8
     2 n_person_sex_cd = f8
     2 o_person_sex_cd = f8
     2 n_ssn = c15
     2 o_ssn = c15
     2 n_person_type_cd = f8
     2 o_person_type_cd = f8
     2 n_autopsy_cd = f8
     2 o_autopsy_cd = f8
     2 n_conception_dt_tm = dq8
     2 o_conception_dt_tm = dq8
     2 n_cause_of_death = c40
     2 o_cause_of_death = c40
     2 n_deceased_cd = f8
     2 o_deceased_cd = f8
     2 n_deceased_dt_tm = dq8
     2 o_deceased_dt_tm = dq8
     2 n_ethnic_grp_cd = f8
     2 o_ethnic_grp_cd = f8
     2 n_language_cd = f8
     2 o_language_cd = f8
     2 n_marital_type_cd = f8
     2 o_marital_type_cd = f8
     2 n_race_cd = f8
     2 o_race_cd = f8
     2 n_religion_cd = f8
     2 o_religion_cd = f8
     2 n_sex_age_chg_ind_ind = i2
     2 n_sex_age_chg_ind = i2
     2 o_sex_age_chg_ind_ind = i2
     2 o_sex_age_chg_ind = i2
     2 n_lang_dialect_cd = f8
     2 o_lang_dialect_cd = f8
     2 n_species_cd = f8
     2 o_species_cd = f8
     2 n_confid_level_cd = f8
     2 o_confid_level_cd = f8
     2 n_person_vip_cd = f8
     2 o_person_vip_cd = f8
     2 n_citizenship_cd = f8
     2 o_citizenship_cd = f8
     2 n_vet_mil_stat_cd = f8
     2 o_vet_mil_stat_cd = f8
     2 n_mthr_maid_name = c20
     2 o_mthr_maid_name = c20
     2 n_nationality_cd = f8
     2 o_nationality_cd = f8
     2 n_encntr_class_cd = f8
     2 o_encntr_class_cd = f8
     2 n_encntr_type_cd = f8
     2 o_encntr_type_cd = f8
     2 n_encntr_type_class_cd = f8
     2 o_encntr_type_class_cd = f8
     2 n_encntr_status_cd = f8
     2 o_encntr_status_cd = f8
     2 n_pre_reg_dt_tm = dq8
     2 o_pre_reg_dt_tm = dq8
     2 n_pre_reg_prsnl_id = f8
     2 o_pre_reg_prsnl_id = f8
     2 n_reg_dt_tm = dq8
     2 o_reg_dt_tm = dq8
     2 n_reg_prsnl_id = f8
     2 o_reg_prsnl_id = f8
     2 n_est_arrive_dt_tm = dq8
     2 o_est_arrive_dt_tm = dq8
     2 n_est_depart_dt_tm = dq8
     2 o_est_depart_dt_tm = dq8
     2 n_arrive_dt_tm = dq8
     2 o_arrive_dt_tm = dq8
     2 n_depart_dt_tm = dq8
     2 o_depart_dt_tm = dq8
     2 n_admit_type_cd = f8
     2 o_admit_type_cd = f8
     2 n_admit_src_cd = f8
     2 o_admit_src_cd = f8
     2 n_admit_mode_cd = f8
     2 o_admit_mode_cd = f8
     2 n_admit_with_med_cd = f8
     2 o_admit_with_med_cd = f8
     2 n_refer_comment = c40
     2 o_refer_comment = c40
     2 n_disch_disp_cd = f8
     2 o_disch_disp_cd = f8
     2 n_disch_to_loctn_cd = f8
     2 o_disch_to_loctn_cd = f8
     2 n_preadmit_nbr = c20
     2 o_preadmit_nbr = c20
     2 n_preadmit_test_cd = f8
     2 o_preadmit_test_cd = f8
     2 n_readmit_cd = f8
     2 o_readmit_cd = f8
     2 n_accom_cd = f8
     2 o_accom_cd = f8
     2 n_accom_req_cd = f8
     2 o_accom_req_cd = f8
     2 n_alt_result_dest_cd = f8
     2 o_alt_result_dest_cd = f8
     2 n_amb_cond_cd = f8
     2 o_amb_cond_cd = f8
     2 n_courtesy_cd = f8
     2 o_courtesy_cd = f8
     2 n_diet_type_cd = f8
     2 o_diet_type_cd = f8
     2 n_isolation_cd = f8
     2 o_isolation_cd = f8
     2 n_med_service_cd = f8
     2 o_med_service_cd = f8
     2 n_result_dest_cd = f8
     2 o_result_dest_cd = f8
     2 n_encntr_vip_cd = f8
     2 o_encntr_vip_cd = f8
     2 n_encntr_sex_cd = f8
     2 o_encntr_sex_cd = f8
     2 n_disch_dt_tm = dq8
     2 o_disch_dt_tm = dq8
     2 n_guar_type_cd = f8
     2 o_guar_type_cd = f8
     2 n_loc_temp_cd = f8
     2 o_loc_temp_cd = f8
     2 n_reason_for_visit = c40
     2 o_reason_for_visit = c40
     2 n_fin_class_cd = f8
     2 o_fin_class_cd = f8
     2 n_location_cd = f8
     2 o_location_cd = f8
     2 n_loc_facility_cd = f8
     2 o_loc_facility_cd = f8
     2 n_loc_building_cd = f8
     2 o_loc_building_cd = f8
     2 n_loc_nurse_unit_cd = f8
     2 o_loc_nurse_unit_cd = f8
     2 n_loc_room_cd = f8
     2 o_loc_room_cd = f8
     2 n_loc_bed_cd = f8
     2 o_loc_bed_cd = f8
     2 n_admit_doc_name = c30
     2 o_admit_doc_name = c30
     2 n_admit_doc_id = f8
     2 o_admit_doc_id = f8
     2 n_attend_doc_name = c30
     2 o_attend_doc_name = c30
     2 n_attend_doc_id = f8
     2 o_attend_doc_id = f8
     2 n_consult_doc_name = c30
     2 o_consult_doc_name = c30
     2 n_consult_doc_id = f8
     2 o_consult_doc_id = f8
     2 n_refer_doc_name = c30
     2 o_refer_doc_name = c30
     2 n_refer_doc_id = f8
     2 o_refer_doc_id = f8
     2 n_admit_doc_nbr = c16
     2 o_admit_doc_nbr = c16
     2 n_attend_doc_nbr = c16
     2 o_attend_doc_nbr = c16
     2 n_consult_doc_nbr = c16
     2 o_consult_doc_nbr = c16
     2 n_refer_doc_nbr = c16
     2 o_refer_doc_nbr = c16
     2 n_per_home_address_id = f8
     2 o_per_home_address_id = f8
     2 n_per_home_addr_street = c100
     2 o_per_home_addr_street = c100
     2 n_per_home_addr_city = c40
     2 o_per_home_addr_city = c40
     2 n_per_home_addr_state = c20
     2 o_per_home_addr_state = c20
     2 n_per_home_addr_zipcode = c20
     2 o_per_home_addr_zipcode = c20
     2 n_per_bus_address_id = f8
     2 o_per_bus_address_id = f8
     2 n_per_bus_addr_street = c100
     2 o_per_bus_addr_street = c100
     2 n_per_bus_addr_city = c40
     2 o_per_bus_addr_city = c40
     2 n_per_bus_addr_state = c20
     2 o_per_bus_addr_state = c20
     2 n_per_bus_addr_zipcode = c20
     2 o_per_bus_addr_zipcode = c20
     2 n_per_home_phone_id = f8
     2 o_per_home_phone_id = f8
     2 n_per_home_ph_format_cd = f8
     2 o_per_home_ph_format_cd = f8
     2 n_per_home_ph_number = c20
     2 o_per_home_ph_number = c20
     2 n_per_home_ext = c10
     2 o_per_home_ext = c10
     2 n_per_bus_phone_id = f8
     2 o_per_bus_phone_id = f8
     2 n_per_bus_ph_format_cd = f8
     2 o_per_bus_ph_format_cd = f8
     2 n_per_bus_ph_number = c20
     2 o_per_bus_ph_number = c20
     2 n_per_bus_ext = c10
     2 o_per_bus_ext = c10
     2 n_per_home_addr_street2 = c100
     2 o_per_home_addr_street2 = c100
     2 n_per_bus_addr_street2 = c100
     2 o_per_bus_addr_street2 = c100
     2 n_per_home_addr_county = c20
     2 o_per_home_addr_county = c20
     2 n_per_home_addr_country = c20
     2 o_per_home_addr_country = c20
     2 n_per_bus_addr_county = c20
     2 o_per_bus_addr_county = c20
     2 n_per_bus_addr_country = c20
     2 o_per_bus_addr_country = c20
     2 n_encntr_complete_dt_tm = dq8
     2 o_encntr_complete_dt_tm = dq8
     2 n_organization_id = f8
     2 o_organization_id = f8
     2 n_contributor_system_cd = f8
     2 o_contributor_system_cd = f8
     2 hl7_event = c10
     2 n_assign_to_loc_dt_tm = dq8
     2 o_assign_to_loc_dt_tm = dq8
     2 n_alt_lvl_care_cd = f8
     2 o_alt_lvl_care_cd = f8
     2 n_program_service_cd = f8
     2 o_program_service_cd = f8
     2 n_specialty_unit_cd = f8
     2 o_specialty_unit_cd = f8
     2 n_birth_tz = i4
     2 o_birth_tz = i4
     2 abs_n_birth_dt_tm = dq8
     2 abs_o_birth_dt_tm = dq8
     2 n_service_category_cd = f8
     2 o_service_category_cd = f8
     2 n_person_birth_sex_cd = f8
     2 o_person_birth_sex_cd = f8
   1 facility_org_id = f8
 ) WITH protect
 FREE SET rep_101131
 RECORD rep_101131 (
   1 trans
     2 transaction_id = f8
     2 pm_hist_tracking_id = f8
     2 activity_dt_tm = dq8
     2 transaction_dt_tm = dq8
     2 transaction = c4
     2 n_person_id = f8
     2 o_person_id = f8
     2 n_encntr_id = f8
     2 o_encntr_id = f8
     2 n_encntr_fin_id = f8
     2 o_encntr_fin_id = f8
     2 n_mrn = c20
     2 o_mrn = c20
     2 n_fin_nbr = c20
     2 o_fin_nbr = c20
     2 n_name_last = c20
     2 o_name_last = c20
     2 n_name_first = c20
     2 o_name_first = c20
     2 n_name_middle = c20
     2 o_name_middle = c20
     2 n_name_formatted = c30
     2 o_name_formatted = c30
     2 n_birth_dt_cd = f8
     2 o_birth_dt_cd = f8
     2 n_birth_dt_tm = dq8
     2 o_birth_dt_tm = dq8
     2 n_person_sex_cd = f8
     2 o_person_sex_cd = f8
     2 n_ssn = c15
     2 o_ssn = c15
     2 n_person_type_cd = f8
     2 o_person_type_cd = f8
     2 n_autopsy_cd = f8
     2 o_autopsy_cd = f8
     2 n_conception_dt_tm = dq8
     2 o_conception_dt_tm = dq8
     2 n_cause_of_death = c40
     2 o_cause_of_death = c40
     2 n_deceased_cd = f8
     2 o_deceased_cd = f8
     2 n_deceased_dt_tm = dq8
     2 o_deceased_dt_tm = dq8
     2 n_ethnic_grp_cd = f8
     2 o_ethnic_grp_cd = f8
     2 n_language_cd = f8
     2 o_language_cd = f8
     2 n_marital_type_cd = f8
     2 o_marital_type_cd = f8
     2 n_race_cd = f8
     2 o_race_cd = f8
     2 n_religion_cd = f8
     2 o_religion_cd = f8
     2 n_sex_age_chg_ind_ind = i2
     2 n_sex_age_chg_ind = i2
     2 o_sex_age_chg_ind_ind = i2
     2 o_sex_age_chg_ind = i2
     2 n_lang_dialect_cd = f8
     2 o_lang_dialect_cd = f8
     2 n_species_cd = f8
     2 o_species_cd = f8
     2 n_confid_level_cd = f8
     2 o_confid_level_cd = f8
     2 n_person_vip_cd = f8
     2 o_person_vip_cd = f8
     2 n_citizenship_cd = f8
     2 o_citizenship_cd = f8
     2 n_vet_mil_stat_cd = f8
     2 o_vet_mil_stat_cd = f8
     2 n_mthr_maid_name = c20
     2 o_mthr_maid_name = c20
     2 n_nationality_cd = f8
     2 o_nationality_cd = f8
     2 n_encntr_class_cd = f8
     2 o_encntr_class_cd = f8
     2 n_encntr_type_cd = f8
     2 o_encntr_type_cd = f8
     2 n_encntr_type_class_cd = f8
     2 o_encntr_type_class_cd = f8
     2 n_encntr_status_cd = f8
     2 o_encntr_status_cd = f8
     2 n_pre_reg_dt_tm = dq8
     2 o_pre_reg_dt_tm = dq8
     2 n_pre_reg_prsnl_id = f8
     2 o_pre_reg_prsnl_id = f8
     2 n_reg_dt_tm = dq8
     2 o_reg_dt_tm = dq8
     2 n_reg_prsnl_id = f8
     2 o_reg_prsnl_id = f8
     2 n_est_arrive_dt_tm = dq8
     2 o_est_arrive_dt_tm = dq8
     2 n_est_depart_dt_tm = dq8
     2 o_est_depart_dt_tm = dq8
     2 n_arrive_dt_tm = dq8
     2 o_arrive_dt_tm = dq8
     2 n_depart_dt_tm = dq8
     2 o_depart_dt_tm = dq8
     2 n_admit_type_cd = f8
     2 o_admit_type_cd = f8
     2 n_admit_src_cd = f8
     2 o_admit_src_cd = f8
     2 n_admit_mode_cd = f8
     2 o_admit_mode_cd = f8
     2 n_admit_with_med_cd = f8
     2 o_admit_with_med_cd = f8
     2 n_refer_comment = c40
     2 o_refer_comment = c40
     2 n_disch_disp_cd = f8
     2 o_disch_disp_cd = f8
     2 n_disch_to_loctn_cd = f8
     2 o_disch_to_loctn_cd = f8
     2 n_preadmit_nbr = c20
     2 o_preadmit_nbr = c20
     2 n_preadmit_test_cd = f8
     2 o_preadmit_test_cd = f8
     2 n_readmit_cd = f8
     2 o_readmit_cd = f8
     2 n_accom_cd = f8
     2 o_accom_cd = f8
     2 n_accom_req_cd = f8
     2 o_accom_req_cd = f8
     2 n_alt_result_dest_cd = f8
     2 o_alt_result_dest_cd = f8
     2 n_amb_cond_cd = f8
     2 o_amb_cond_cd = f8
     2 n_courtesy_cd = f8
     2 o_courtesy_cd = f8
     2 n_diet_type_cd = f8
     2 o_diet_type_cd = f8
     2 n_isolation_cd = f8
     2 o_isolation_cd = f8
     2 n_med_service_cd = f8
     2 o_med_service_cd = f8
     2 n_result_dest_cd = f8
     2 o_result_dest_cd = f8
     2 n_encntr_vip_cd = f8
     2 o_encntr_vip_cd = f8
     2 n_encntr_sex_cd = f8
     2 o_encntr_sex_cd = f8
     2 n_disch_dt_tm = dq8
     2 o_disch_dt_tm = dq8
     2 n_guar_type_cd = f8
     2 o_guar_type_cd = f8
     2 n_loc_temp_cd = f8
     2 o_loc_temp_cd = f8
     2 n_reason_for_visit = c40
     2 o_reason_for_visit = c40
     2 n_fin_class_cd = f8
     2 o_fin_class_cd = f8
     2 n_location_cd = f8
     2 o_location_cd = f8
     2 n_loc_facility_cd = f8
     2 o_loc_facility_cd = f8
     2 n_loc_building_cd = f8
     2 o_loc_building_cd = f8
     2 n_loc_nurse_unit_cd = f8
     2 o_loc_nurse_unit_cd = f8
     2 n_loc_room_cd = f8
     2 o_loc_room_cd = f8
     2 n_loc_bed_cd = f8
     2 o_loc_bed_cd = f8
     2 n_admit_doc_name = c30
     2 o_admit_doc_name = c30
     2 n_admit_doc_id = f8
     2 o_admit_doc_id = f8
     2 n_attend_doc_name = c30
     2 o_attend_doc_name = c30
     2 n_attend_doc_id = f8
     2 o_attend_doc_id = f8
     2 n_consult_doc_name = c30
     2 o_consult_doc_name = c30
     2 n_consult_doc_id = f8
     2 o_consult_doc_id = f8
     2 n_refer_doc_name = c30
     2 o_refer_doc_name = c30
     2 n_refer_doc_id = f8
     2 o_refer_doc_id = f8
     2 n_admit_doc_nbr = c16
     2 o_admit_doc_nbr = c16
     2 n_attend_doc_nbr = c16
     2 o_attend_doc_nbr = c16
     2 n_consult_doc_nbr = c16
     2 o_consult_doc_nbr = c16
     2 n_refer_doc_nbr = c16
     2 o_refer_doc_nbr = c16
     2 n_per_home_address_id = f8
     2 o_per_home_address_id = f8
     2 n_per_home_addr_street = c100
     2 o_per_home_addr_street = c100
     2 n_per_home_addr_city = c40
     2 o_per_home_addr_city = c40
     2 n_per_home_addr_state = c20
     2 o_per_home_addr_state = c20
     2 n_per_home_addr_zipcode = c20
     2 o_per_home_addr_zipcode = c20
     2 n_per_bus_address_id = f8
     2 o_per_bus_address_id = f8
     2 n_per_bus_addr_street = c100
     2 o_per_bus_addr_street = c100
     2 n_per_bus_addr_city = c40
     2 o_per_bus_addr_city = c40
     2 n_per_bus_addr_state = c20
     2 o_per_bus_addr_state = c20
     2 n_per_bus_addr_zipcode = c20
     2 o_per_bus_addr_zipcode = c20
     2 n_per_home_phone_id = f8
     2 o_per_home_phone_id = f8
     2 n_per_home_ph_format_cd = f8
     2 o_per_home_ph_format_cd = f8
     2 n_per_home_ph_number = c20
     2 o_per_home_ph_number = c20
     2 n_per_home_ext = c10
     2 o_per_home_ext = c10
     2 n_per_bus_phone_id = f8
     2 o_per_bus_phone_id = f8
     2 n_per_bus_ph_format_cd = f8
     2 o_per_bus_ph_format_cd = f8
     2 n_per_bus_ph_number = c20
     2 o_per_bus_ph_number = c20
     2 n_per_bus_ext = c10
     2 o_per_bus_ext = c10
     2 n_per_home_addr_street2 = c100
     2 o_per_home_addr_street2 = c100
     2 n_per_bus_addr_street2 = c100
     2 o_per_bus_addr_street2 = c100
     2 n_per_home_addr_county = c20
     2 o_per_home_addr_county = c20
     2 n_per_home_addr_country = c20
     2 o_per_home_addr_country = c20
     2 n_per_bus_addr_county = c20
     2 o_per_bus_addr_county = c20
     2 n_per_bus_addr_country = c20
     2 o_per_bus_addr_country = c20
     2 n_encntr_complete_dt_tm = dq8
     2 o_encntr_complete_dt_tm = dq8
     2 n_organization_id = f8
     2 o_organization_id = f8
     2 n_contributor_system_cd = f8
     2 o_contributor_system_cd = f8
     2 n_assign_to_loc_dt_tm = dq8
     2 o_assign_to_loc_dt_tm = dq8
     2 n_alt_lvl_care_cd = f8
     2 o_alt_lvl_care_cd = f8
     2 n_program_service_cd = f8
     2 o_program_service_cd = f8
     2 n_specialty_unit_cd = f8
     2 o_specialty_unit_cd = f8
     2 n_birth_tz = i4
     2 o_birth_tz = i4
     2 abs_n_birth_dt_tm = dq8
     2 abs_o_birth_dt_tm = dq8
     2 n_service_category_cd = f8
     2 o_service_category_cd = f8
     2 output_dest_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE SET flagstaging
 RECORD flagstaging (
   1 qual [* ]
     2 flag_cd = f8
     2 include = i1
 ) WITH protect
 IF (size (request->clinic_flag ,5 ) )
  FOR (i = 1 TO size (request->clinic_flag ,5 ) )
   IF (NOT (iscodeoncodeset (request->clinic_flag[i ].flag_cd ,race_cs ) ) )
    CALL setstat (stat_err ,build2 ("The input code value [" ,request->clinic_flag[i ].flag_cd ,
      "] was not found on cs " ,race_cs ) )
    GO TO exit_script
   ENDIF
  ENDFOR
 ENDIF
 IF (size (request->disease_flag ,5 ) )
  FOR (i = 1 TO size (request->disease_flag ,5 ) )
   IF (NOT (iscodeoncodeset (request->disease_flag[i ].flag_cd ,disease_alert_cs ) ) )
    CALL setstat (stat_err ,build2 ("The input code value [" ,request->disease_flag[i ].flag_cd ,
      "] was not found on cs " ,disease_alert_cs ) )
    GO TO exit_script
   ENDIF
  ENDFOR
 ENDIF
 IF (size (request->process_flag ,5 ) )
  FOR (i = 1 TO size (request->process_flag ,5 ) )
   IF (NOT (iscodeoncodeset (request->process_flag[i ].flag_cd ,process_alert_cs ) ) )
    CALL setstat (stat_err ,build2 ("The input code value [" ,request->process_flag[i ].flag_cd ,
      "] was not found on cs " ,process_alert_cs ) )
    GO TO exit_script
   ENDIF
  ENDFOR
 ENDIF
 IF ((request->isolation_flag.flag_cd > 0.0 ) )
  IF (NOT (iscodeoncodeset (request->isolation_flag.flag_cd ,isolation_cs ) ) )
   CALL setstat (stat_err ,build2 ("The input code value [" ,request->isolation_flag.flag_cd ,
     "] was not found on cs " ,isolation_cs ) )
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((errorcheck ("INIT" ,"CODE_VALUES" ) > 0 ) )
  CALL setstat (stat_err ,"Unexpected error occurred during initialization" )
  GO TO exit_script
 ENDIF
 CASE (buildandprocessrequests (null ) )
  OF true :
   CALL setstat (stat_succ )
  OF 2 :
   CALL setstat (stat_none )
  ELSE
   CALL setstat (stat_err )
 ENDCASE
 SUBROUTINE  (callpmenstransaction (null ) =i1 )
  CALL logdebugmsg ("Inside callPmEnsTransaction()" )
  IF (testind )
   SET pm_hist_tracking_id = 123
   SET pm_trans_id = 123
   CALL logdebugmsg ("testInd=true, not executing pm_ens_transaction." )
   RETURN (true )
  ENDIF
  IF ((pm_hist_tracking_id = 0.0 ) )
   IF (request->encntr_id )
    SET req_101131->transaction = "UPDT"
    SET req_101131->encntr_id = request->encntr_id
   ELSE
    SET req_101131->transaction = "UMPI"
   ENDIF
   SET req_101131->transaction_reason = concat ("CUSTOM CCL: " ,getparentprog (null ) )
   SET req_101131->transaction_dt_tm = cnvtdatetime (sysdate )
   SET req_101131->person_id = request->person_id
  ENDIF
  EXECUTE pm_ens_transaction WITH replace ("REQUEST" ,req_101131 ) ,
  replace ("REPLY" ,rep_101131 )
  IF ((rep_101131->status_data.status != "S" ) )
   CALL logerrormsg ("101131 failed!" )
   CALL echorec (rep_101131 )
   RETURN (false )
  ELSE
   COMMIT
   SET req_101131->transaction_id = rep_101131->transaction_id
   SET pm_hist_tracking_id = rep_101131->trans.pm_hist_tracking_id
   SET pm_trans_id = rep_101131->trans.transaction_id
  ENDIF
  RETURN (true )
 END ;Subroutine
 SUBROUTINE  (buildandprocessrequests (null ) =i1 )
  DECLARE processalertschanged = i1 WITH noconstant (false ) ,protect
  DECLARE diseasealertschanged = i1 WITH noconstant (false ) ,protect
  DECLARE execute101101request = i1 WITH noconstant (false ) ,protect
  DECLARE execute101104request = i1 WITH noconstant (false ) ,protect
  DECLARE execute101301request = i1 WITH noconstant (false ) ,protect
  IF (size (request->clinic_flag ,5 ) )
   IF (buildclinicflags (null ) )
    SET execute101101request = true
   ENDIF
  ENDIF
  IF (size (request->disease_flag ,5 ) )
   IF (builddiseaseflags (null ) )
    SET diseasealertschanged = true
    SET execute101104request = true
   ENDIF
  ENDIF
  IF (size (request->process_flag ,5 ) )
   IF (buildprocessflags (null ) )
    SET processalertschanged = true
    SET execute101104request = true
   ENDIF
  ENDIF
  IF (((processalertschanged ) OR (diseasealertschanged )) )
   IF (recalculatepatientalerts (processalertschanged ,diseasealertschanged ) )
    SET execute101101request = true
   ENDIF
  ENDIF
  IF ((((request->isolation_flag.flag_cd < 0.0 ) ) OR (request->isolation_flag.remove_ind )) )
   SET request->isolation_flag.flag_cd = - (1.0 )
  ENDIF
  IF (buildisolationflagrequest (null ) )
   SET execute101301request = true
  ENDIF
  CALL logdebugmsg (build ("execute101104Request=" ,execute101104request ) )
  CALL logdebugmsg (build ("execute101101Request=" ,execute101101request ) )
  CALL logdebugmsg (build ("execute101301Request=" ,execute101301request ) )
  IF (testind )
   CALL loginfomsg ("Testing mode, skipping calls to PM servers." )
   CALL echorec (req_101301 )
   CALL echorec (req_101104 )
   CALL echorec (req_101101 )
   RETURN (2 )
  ENDIF
  IF (execute101301request )
   CALL echorec (req_101301 )
   SET stat = tdbexecute (100000 ,100005 ,101301 ,"REC" ,req_101301 ,"REC" ,rep_101301 )
   IF (((stat ) OR ((rep_101301->status_data.status != "S" ) )) )
    CALL logerrormsg ("Call to 101301 failed!" )
    CALL echorec (rep_101301 )
    RETURN (false )
   ENDIF
  ENDIF
  IF (execute101104request )
   CALL echorec (req_101104 )
   SET stat = tdbexecute (961000 ,965200 ,101104 ,"REC" ,req_101104 ,"REC" ,rep_101104 )
   IF (((stat ) OR ((rep_101104->status_data.status != "S" ) )) )
    CALL logerrormsg ("Call to 101104 failed!" )
    CALL echorec (rep_101104 )
    RETURN (false )
   ENDIF
  ENDIF
  IF (execute101101request )
   CALL echorec (req_101101 )
   SET stat = tdbexecute (100000 ,100005 ,101101 ,"REC" ,req_101101 ,"REC" ,rep_101101 )
   IF (((stat ) OR ((rep_101101->status_data.status != "S" ) )) )
    CALL logerrormsg ("Call to 101101 failed!" )
    CALL echorec (rep_101101 )
    RETURN (false )
   ENDIF
  ENDIF
  IF (pm_hist_tracking_id )
   IF (callpmenstransaction (null ) )
    EXECUTE pm_call_post_transaction WITH replace ("REQUEST" ,rep_101131 )
    CALL loginfomsg ("Calls to PM servers completed successfully" )
    IF (NOT (maybetriggeradts (null ) ) )
     RETURN (false )
    ENDIF
   ELSE
    RETURN (false )
   ENDIF
  ELSE
   CALL loginfomsg ("No changes to this person detected - no calls to PM servers required" )
   RETURN (2 )
  ENDIF
  IF (errorcheck ("SELECT" ,"buildAndProcessRequests" ) )
   CALL logwarnmsg ("An error occurred." )
   RETURN (false )
  ENDIF
  RETURN (true )
 END ;Subroutine
 SUBROUTINE  (buildisolationflagrequest (null ) =i1 )
  IF ((request->isolation_flag.flag_cd = 0.0 ) )
   RETURN (false )
  ENDIF
  SELECT
   IF ((request->isolation_flag.flag_cd < 0.0 ) )
    WHERE (e.encntr_id = request->encntr_id )
    AND (e.isolation_cd > 0.0 )
   ELSE
   ENDIF
   INTO "NL:"
   FROM (encounter e )
   WHERE (e.encntr_id = request->encntr_id )
   AND (e.isolation_cd != request->isolation_flag.flag_cd )
   WITH nocounter
  ;end select
  IF (curqual )
   CALL maybeinit101301 (null )
   SET req_101301->encounter[1 ].isolation_cd = request->isolation_flag.flag_cd
   RETURN (true )
  ENDIF
  RETURN (false )
 END ;Subroutine
 SUBROUTINE  (maybetriggeradts (null ) =i1 )
  IF (size (request->adts ,5 ) )
   EXECUTE phsa_lib_adt
   FOR (i = 1 TO size (request->adts ,5 ) )
    IF (NOT ((request->adts[i ].trigger IN ("A31" ,
    "A08" ) ) ) )
     CALL logerrormsg (build ("The input adt trigger [" ,request->adts[i ].trigger ,
       "] is not supported. Skipping!" ) )
    ELSE
     IF ((request->adts[i ].trigger = "A08" )
     AND (request->encntr_id = 0.0 ) )
      CALL logerrormsg (
       "ADT Trigger of A08 is specified but no encounter was included in the request" )
      RETURN (false )
     ENDIF
     CALL loginfomsg (build2 ("Sending " ,request->adts[i ].trigger ) )
     IF (send_adt_outbound (request->person_id ,request->encntr_id ,rep_101131->trans.transaction_id
      ,request->adts[i ].trigger ) )
      CALL loginfomsg (build2 (request->adts[i ].trigger ," successfully generated!" ) )
     ELSE
      CALL logerrormsg (build2 ("Error occurred while attempting to send " ,request->adts[i ].trigger
         ) )
      CALL echorec (err )
      RETURN (false )
     ENDIF
    ENDIF
   ENDFOR
  ELSE
   CALL logdebugmsg ("Not triggering ADTs" )
  ENDIF
  RETURN (true )
 END ;Subroutine
 SUBROUTINE  (recalculatepatientalerts (withprocessind =i1 ,withdiseaseind =i1 ) =null )
  CALL loginfomsg ("Recalculating patient's alerts..." )
  DECLARE diseaseprocessinterpreter_cd = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,14652 ,
    "DISEASEPROCESSINTERPRETER" ) ) ,protect
  DECLARE diseaseinterpreter_cd = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,14652 ,
    "DISEASEINTERPRETER" ) ) ,protect
  DECLARE processalert_cd = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,14652 ,"PROCESSALERT" )
   ) ,protect
  DECLARE diseaseprocessalerts_cd = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,14652 ,
    "DISEASEPROCESSALERTS" ) ) ,protect
  DECLARE diseasealert_cd = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,14652 ,"DISEASEALERT" )
   ) ,protect
  DECLARE processinterpreter_cd = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,14652 ,
    "PROCESSINTERPRETER" ) ) ,protect
  DECLARE interpreterrequired_cd = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,14652 ,
    "INTERPRETERREQUIRED" ) ) ,protect
  IF ((- (1.0 ) IN (diseaseprocessinterpreter_cd ,
  diseaseinterpreter_cd ,
  processalert_cd ,
  diseaseprocessalerts_cd ,
  diseasealert_cd ,
  processinterpreter_cd ,
  interpreterrequired_cd ) ) )
   CALL logerrormsg ("Error getting code values!" )
   RETURN (false )
  ENDIF
  DECLARE proc_ind = i1 WITH noconstant (false )
  DECLARE disease_ind = i1 WITH noconstant (false )
  DECLARE interp_ind = i1 WITH noconstant (false )
  DECLARE currentnatcd = f8 WITH protect
  DECLARE newnatcd = f8 WITH protect
  SELECT INTO "NL:"
   FROM (person p ),
    (person_patient pp ),
    (person_code_value_r m )
   PLAN (p
    WHERE (p.person_id = request->person_id )
    AND (p.active_ind = 1 )
    AND (cnvtdatetime (sysdate ) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm ) )
    JOIN (pp
    WHERE (pp.person_id = p.person_id )
    AND (pp.active_ind = 1 )
    AND (cnvtdatetime (sysdate ) BETWEEN pp.beg_effective_dt_tm AND pp.end_effective_dt_tm ) )
    JOIN (m
    WHERE (m.person_id = Outerjoin(p.person_id ))
    AND (m.active_ind = Outerjoin(1 )) )
   ORDER BY p.person_id ,
    m.code_value
   HEAD p.person_id
    currentnatcd = p.nationality_cd ,
    IF ((pp.disease_alert_cd > 0.0 ) ) disease_ind = true
    ENDIF
    ,
    IF ((pp.process_alert_cd > 0.0 ) ) proc_ind = true
    ENDIF
    ,
    IF ((pp.interp_required_cd > 0.0 ) ) interp_ind = true
    ENDIF
   DETAIL
    IF ((m.code_value > 0.0 ) )
     IF ((m.code_set = disease_alert_cs ) ) disease_ind = true
     ELSEIF ((m.code_set = process_alert_cs ) ) proc_ind = true
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (withprocessind )
   IF (size (req_101104->person_patient[1 ].process_alert ,5 ) )
    IF ((req_101104->person_patient[1 ].process_alert[1 ].value_cd > 0.0 ) )
     SET proc_ind = true
    ELSE
     SET proc_ind = false
    ENDIF
   ELSE
    SET proc_ind = false
   ENDIF
  ENDIF
  IF (withdiseaseind )
   IF (size (req_101104->person_patient[1 ].disease_alert ,5 ) )
    IF ((req_101104->person_patient[1 ].disease_alert[1 ].value_cd > 0.0 ) )
     SET disease_ind = true
    ELSE
     SET disease_ind = false
    ENDIF
   ELSE
    SET disease_ind = false
   ENDIF
  ENDIF
  IF (proc_ind
  AND disease_ind
  AND interp_ind )
   SET newnatcd = diseaseprocessinterpreter_cd
  ELSEIF (proc_ind
  AND NOT (disease_ind )
  AND interp_ind )
   SET newnatcd = processinterpreter_cd
  ELSEIF (NOT (proc_ind )
  AND disease_ind
  AND NOT (interp_ind ) )
   SET newnatcd = diseasealert_cd
  ELSEIF (proc_ind
  AND disease_ind
  AND NOT (interp_ind ) )
   SET newnatcd = diseaseprocessalerts_cd
  ELSEIF (proc_ind
  AND NOT (disease_ind )
  AND NOT (interp_ind ) )
   SET newnatcd = processalert_cd
  ELSEIF (NOT (proc_ind )
  AND disease_ind
  AND NOT (interp_ind ) )
   SET newnatcd = diseasealert_cd
  ELSEIF (NOT (proc_ind )
  AND disease_ind
  AND interp_ind )
   SET newnatcd = diseaseinterpreter_cd
  ELSE
   SET newnatcd = - (1.0 )
  ENDIF
  CALL loginfomsg (build ("Current alerts summary:[" ,uar_get_code_display (currentnatcd ) ,
    "] new alert summary: [" ,uar_get_code_display (newnatcd ) ,"]" ) )
  IF ((newnatcd = currentnatcd ) )
   CALL logdebugmsg ("The patient already has the appropriate alerts." )
   RETURN (false )
  ELSE
   CALL maybeinit101101 (null )
   SET req_101101->person[1 ].nationality_cd = newnatcd
   RETURN (true )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (buildprocessflags (null ) =i1 )
  DECLARE i = i4 WITH protect
  DECLARE j = i4 WITH protect
  DECLARE pos = i4 WITH protect
  DECLARE nextpos = i4 WITH protect
  DECLARE totalmods = i4 WITH noconstant (0 ) ,protect
  DECLARE newreqsize = i4 WITH protect
  SET stat = initrec (flagstaging )
  SELECT INTO "NL:"
   FROM (person_patient p ),
    (person_code_value_r m )
   PLAN (p
    WHERE (p.person_id = request->person_id )
    AND (p.active_ind = 1 )
    AND (cnvtdatetime (sysdate ) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm ) )
    JOIN (m
    WHERE (m.person_id = Outerjoin(p.person_id ))
    AND (m.code_value != Outerjoin(p.process_alert_cd ))
    AND (m.active_ind = Outerjoin(1 ))
    AND (m.code_set = Outerjoin(process_alert_cs )) )
   ORDER BY p.person_id ,
    m.code_value
   HEAD REPORT
    cnt = 0
   HEAD p.person_id
    IF ((p.process_alert_cd = process_multi_cd ) )
     CALL logdebugmsg (build ("The existing code [" ,p.process_alert_cd ,"] found for person_id [" ,p
      .person_id ,"] is a multiselect, will look at PERSON_CODE_VALUE_R." ) )
    ELSE
     IF ((p.process_alert_cd > 0 ) ) cnt +=1 ,
      CALL alterlist (flagstaging->qual ,cnt ) ,flagstaging->qual[cnt ].flag_cd = p.process_alert_cd
     ,flagstaging->qual[cnt ].include = true
     ENDIF
    ENDIF
   HEAD m.code_value
    IF ((m.code_value > 0.0 ) ) cnt +=1 ,
     CALL alterlist (flagstaging->qual ,cnt ) ,flagstaging->qual[cnt ].flag_cd = m.code_value ,
     flagstaging->qual[cnt ].include = true
    ENDIF
   FOOT REPORT
    newreqsize = cnt
   WITH nocounter
  ;end select
  FOR (i = 1 TO size (request->process_flag ,5 ) )
   SET pos = locateval (j ,1 ,size (flagstaging->qual ,5 ) ,request->process_flag[i ].flag_cd ,
    flagstaging->qual[j ].flag_cd )
   IF (pos )
    IF (request->process_flag[i ].remove_ind )
     SET flagstaging->qual[pos ].include = false
     SET totalmods +=1
     SET newreqsize -=1
    ENDIF
   ELSE
    IF (NOT (request->process_flag[i ].remove_ind ) )
     SET nextpos = (size (flagstaging->qual ,5 ) + 1 )
     CALL alterlist (flagstaging->qual ,nextpos )
     SET flagstaging->qual[nextpos ].flag_cd = request->process_flag[i ].flag_cd
     SET flagstaging->qual[nextpos ].include = true
     SET totalmods +=1
     SET newreqsize +=1
    ENDIF
   ENDIF
  ENDFOR
  CALL logdebugmsg (build ("totalMods=" ,totalmods ," ,newReqSize=" ,newreqsize ) )
  IF (totalmods )
   CALL maybeinit101104 (null )
   IF (newreqsize )
    SET req_101104->person_patient[1 ].process_alert_cd = process_multi_cd
    SET req_101104->person_patient[1 ].process_alert_list_ind = true
    CALL alterlist (req_101104->person_patient[1 ].process_alert ,newreqsize )
    SET j = 0
    FOR (i = 1 TO size (flagstaging->qual ,5 ) )
     IF (flagstaging->qual[i ].include )
      SET j +=1
      SET req_101104->person_patient[1 ].process_alert[j ].value_cd = flagstaging->qual[i ].flag_cd
     ENDIF
    ENDFOR
   ELSE
    CALL alterlist (req_101104->person_patient[1 ].process_alert ,1 )
    SET req_101104->person_patient[1 ].process_alert_cd = - (1.0 )
    SET req_101104->person_patient[1 ].process_alert_list_ind = 1
    SET req_101104->person_patient[1 ].process_alert[1 ].value_cd = - (1.0 )
   ENDIF
   RETURN (true )
  ELSE
   RETURN (false )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (getpm_hist_tracking_id (null ) =f8 )
  IF ((pm_hist_tracking_id <= 0.0 ) )
   IF (NOT (callpmenstransaction (null ) ) )
    CALL logerrormsg ("ERROR CALLING PM_ENS_TRANSACTION" )
    GO TO exit_script
   ENDIF
  ENDIF
  RETURN (pm_hist_tracking_id )
 END ;Subroutine
 SUBROUTINE  (builddiseaseflags (null ) =i1 )
  CALL logdebugmsg ("Inside buildDiseaseFlags()" )
  DECLARE i = i4 WITH protect
  DECLARE j = i4 WITH protect
  DECLARE pos = i4 WITH protect
  DECLARE nextpos = i4 WITH protect
  DECLARE totalmods = i4 WITH noconstant (0 ) ,protect
  DECLARE newreqsize = i4 WITH protect
  SET stat = initrec (flagstaging )
  SELECT INTO "NL:"
   FROM (person_patient p ),
    (person_code_value_r m )
   PLAN (p
    WHERE (p.person_id = request->person_id )
    AND (p.active_ind = 1 )
    AND (cnvtdatetime (sysdate ) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm ) )
    JOIN (m
    WHERE (m.person_id = Outerjoin(p.person_id ))
    AND (m.code_value != Outerjoin(p.disease_alert_cd ))
    AND (m.active_ind = Outerjoin(1 ))
    AND (m.code_set = Outerjoin(disease_alert_cs )) )
   ORDER BY p.person_id ,
    m.code_value
   HEAD REPORT
    cnt = 0
   HEAD p.person_id
    IF ((p.disease_alert_cd = disease_multi_cd ) )
     CALL loginfomsg (build ("The existing code [" ,p.disease_alert_cd ,"] found for person_id [" ,p
      .person_id ,"] is a multiselect, will look at PERSON_CODE_VALUE_R." ) )
    ELSE
     IF ((p.disease_alert_cd > 0 ) ) cnt +=1 ,
      CALL alterlist (flagstaging->qual ,cnt ) ,flagstaging->qual[cnt ].flag_cd = p.disease_alert_cd
     ,flagstaging->qual[cnt ].include = true
     ENDIF
    ENDIF
   HEAD m.code_value
    IF ((m.code_value > 0.0 ) ) cnt +=1 ,
     CALL alterlist (flagstaging->qual ,cnt ) ,flagstaging->qual[cnt ].flag_cd = m.code_value ,
     flagstaging->qual[cnt ].include = true
    ENDIF
   FOOT REPORT
    newreqsize = cnt
   WITH nocounter
  ;end select
  CALL echorec (flagstaging )
  FOR (i = 1 TO size (request->disease_flag ,5 ) )
   SET pos = locateval (j ,1 ,size (flagstaging->qual ,5 ) ,request->disease_flag[i ].flag_cd ,
    flagstaging->qual[j ].flag_cd )
   IF (pos )
    IF (request->disease_flag[i ].remove_ind )
     SET flagstaging->qual[pos ].include = false
     SET totalmods +=1
     SET newreqsize -=1
    ENDIF
   ELSE
    IF (NOT (request->disease_flag[i ].remove_ind ) )
     SET nextpos = (size (flagstaging->qual ,5 ) + 1 )
     CALL alterlist (flagstaging->qual ,nextpos )
     SET flagstaging->qual[nextpos ].flag_cd = request->disease_flag[i ].flag_cd
     SET flagstaging->qual[nextpos ].include = true
     SET totalmods +=1
     SET newreqsize +=1
    ENDIF
   ENDIF
  ENDFOR
  CALL logdebugmsg (build ("totalMods=" ,totalmods ," ,newReqSize=" ,newreqsize ) )
  IF (totalmods )
   CALL maybeinit101104 (null )
   IF (newreqsize )
    CALL alterlist (req_101104->person_patient[1 ].disease_alert ,newreqsize )
    SET req_101104->person_patient[1 ].disease_alert_cd = disease_multi_cd
    SET req_101104->person_patient[1 ].disease_alert_list_ind = true
    SET j = 0
    FOR (i = 1 TO size (flagstaging->qual ,5 ) )
     IF (flagstaging->qual[i ].include )
      SET j +=1
      SET req_101104->person_patient[1 ].disease_alert[j ].value_cd = flagstaging->qual[i ].flag_cd
     ENDIF
    ENDFOR
   ELSE
    CALL alterlist (req_101104->person_patient[1 ].disease_alert ,1 )
    SET req_101104->person_patient[1 ].disease_alert_cd = - (1.0 )
    SET req_101104->person_patient[1 ].disease_alert_list_ind = 1
    SET req_101104->person_patient[1 ].disease_alert[1 ].value_cd = - (1.0 )
   ENDIF
   RETURN (true )
  ELSE
   RETURN (false )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (maybeinit101104 (null ) =null )
  IF ((size (req_101104->person_patient ,5 ) = 0 ) )
   CALL alterlist (req_101104->person_patient ,1 )
   SET req_101104->person_patient_qual = 1
   SET req_101104->esi_ensure_type = "UPT"
   SET req_101104->person_patient[1 ].person_id = request->person_id
   SET req_101104->person_patient[1 ].action_type = "UPT"
   SET req_101104->person_patient[1 ].pm_hist_tracking_id = getpm_hist_tracking_id (null )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (maybeinit101101 (null ) =null )
  IF ((size (req_101101->person ,5 ) = 0 ) )
   CALL alterlist (req_101101->person ,1 )
   SET req_101101->person_qual = 1
   SET req_101101->esi_ensure_type = "UPT"
   SET req_101101->person[1 ].person_id = request->person_id
   SET req_101101->person[1 ].action_type = "UPT"
   SET req_101101->person[1 ].pm_hist_tracking_id = getpm_hist_tracking_id (null )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (maybeinit101301 (null ) =null )
  IF ((size (req_101301->encounter ,5 ) = 0 ) )
   CALL alterlist (req_101301->encounter ,1 )
   SET req_101301->encounter_qual = 1
   SET req_101301->esi_ensure_type = "UPT"
   SET req_101301->encounter[1 ].action_type = "UPT"
   SET req_101301->encounter[1 ].person_id = request->person_id
   SET req_101301->encounter[1 ].encntr_id = request->encntr_id
   SET req_101301->encounter[1 ].pm_hist_tracking_id = getpm_hist_tracking_id (null )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (buildclinicflags (null ) =i1 )
  DECLARE i = i4 WITH protect
  DECLARE j = i4 WITH protect
  DECLARE pos = i4 WITH protect
  DECLARE nextpos = i4 WITH protect
  DECLARE totalmods = i4 WITH noconstant (0 ) ,protect
  DECLARE newreqsize = i4 WITH protect
  SET stat = initrec (flagstaging )
  SELECT INTO "NL:"
   FROM (person p ),
    (person_code_value_r m )
   PLAN (p
    WHERE (p.person_id = request->person_id )
    AND (p.active_ind = 1 )
    AND (cnvtdatetime (sysdate ) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm ) )
    JOIN (m
    WHERE (m.person_id = Outerjoin(p.person_id ))
    AND (m.code_value != Outerjoin(p.race_cd ))
    AND (m.active_ind = Outerjoin(1 ))
    AND (m.code_set = Outerjoin(race_cs )) )
   ORDER BY p.person_id ,
    m.code_value
   HEAD REPORT
    cnt = 0
   HEAD p.person_id
    IF ((p.race_cd = race_multi_cd ) )
     CALL loginfomsg (build ("The existing code [" ,p.race_cd ,"] found for person_id [" ,p
      .person_id ,"] is a multiselect, will look at PERSON_CODE_VALUE_R." ) )
    ELSE
     IF ((p.race_cd > 0.0 ) ) cnt +=1 ,
      CALL alterlist (flagstaging->qual ,cnt ) ,flagstaging->qual[cnt ].flag_cd = p.race_cd ,
      flagstaging->qual[cnt ].include = true
     ENDIF
    ENDIF
   HEAD m.code_value
    IF ((m.code_value > 0.0 ) ) cnt +=1 ,
     CALL alterlist (flagstaging->qual ,cnt ) ,flagstaging->qual[cnt ].flag_cd = m.code_value ,
     flagstaging->qual[cnt ].include = true
    ENDIF
   FOOT REPORT
    newreqsize = cnt
   WITH nocounter
  ;end select
  FOR (i = 1 TO size (request->clinic_flag ,5 ) )
   SET pos = locateval (j ,1 ,size (flagstaging->qual ,5 ) ,request->clinic_flag[i ].flag_cd ,
    flagstaging->qual[j ].flag_cd )
   IF (pos )
    IF (request->clinic_flag[i ].remove_ind )
     SET flagstaging->qual[pos ].include = false
     SET totalmods +=1
     SET newreqsize -=1
    ENDIF
   ELSE
    IF (NOT (request->clinic_flag[i ].remove_ind ) )
     SET nextpos = (size (flagstaging->qual ,5 ) + 1 )
     CALL alterlist (flagstaging->qual ,nextpos )
     SET flagstaging->qual[nextpos ].flag_cd = request->clinic_flag[i ].flag_cd
     SET flagstaging->qual[nextpos ].include = true
     SET totalmods +=1
     SET newreqsize +=1
    ENDIF
   ENDIF
  ENDFOR
  CALL logdebugmsg (build ("totalMods=" ,totalmods ," ,newReqSize=" ,newreqsize ) )
  CALL echorec (flagstaging )
  IF (totalmods )
   CALL maybeinit101101 (null )
   IF (newreqsize )
    CALL alterlist (req_101101->person[1 ].race_list ,newreqsize )
    SET req_101101->person[1 ].pm_hist_tracking_id = pm_hist_tracking_id
    SET req_101101->person[1 ].race_cd = race_multi_cd
    SET req_101101->person[1 ].race_list_ind = true
    SET j = 0
    FOR (i = 1 TO size (flagstaging->qual ,5 ) )
     IF (flagstaging->qual[i ].include )
      SET j +=1
      SET req_101101->person[1 ].race_list[j ].value_cd = flagstaging->qual[i ].flag_cd
     ENDIF
    ENDFOR
   ELSE
    CALL alterlist (req_101101->person[1 ].race_list ,1 )
    SET req_101101->person[1 ].race_cd = - (1.0 )
    SET req_101101->person[1 ].race_list_ind = 1
    SET req_101101->person[1 ].race_list[1 ].value_cd = - (1.0 )
   ENDIF
   RETURN (true )
  ELSE
   RETURN (false )
  ENDIF
 END ;Subroutine
#exit_script
END GO
