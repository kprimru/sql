USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Common].[REFERENCE_LAST]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT 'PERIOD' AS REF_NAME, MAX(LAST) AS REF_DATE
	FROM Common.Period

	UNION ALL

	SELECT 'TAX', MAX(LAST)
	FROM Common.Tax

	UNION ALL

	SELECT 'CONTRACT_SPECIFICATION', MAX(LAST)
	FROM Contract.Specification

	UNION ALL

	SELECT 'CONTRACT_STATUS', MAX(LAST)
	FROM Contract.Status

	UNION ALL

	SELECT 'CONTRACT_NEW_TYPE', MAX(LAST)
	FROM Contract.Type

	UNION ALL

	SELECT 'CONTROL_GROUP', MAX(LAST)
	FROM Control.ControlGroup

	UNION ALL

	SELECT 'ACTIVITY', MAX(AC_LAST)
	FROM dbo.Activity

	UNION ALL

	SELECT 'ADDRESS_TYPE', MAX(AT_LAST)
	FROM dbo.AddressType

	UNION ALL 

	SELECT 'AREA', MAX(AR_LAST)
	FROM dbo.Area

	UNION ALL

	SELECT 'CALENDAR_TYPE', MAX(LAST)
	FROM dbo.CalendarType

	UNION ALL

	SELECT 'CALL_DIRECTION', MAX(LAST)
	FROM dbo.CallDirection

	UNION ALL

	SELECT 'CALL_TYPE', MAX(CallTypeLast)
	FROM dbo.CallTypeTable

	UNION ALL

	SELECT 'CITY', MAX(CT_LAST)
	FROM dbo.City

	UNION ALL

	SELECT 'CLIENT_TYPE', MAX(ClientTypeLast)
	FROM dbo.ClientTypeTable

	UNION ALL
	
	SELECT 'CLIENT_VISIT_COUNT', MAX(LAST)
	FROM dbo.ClientVisitCount

	UNION ALL

	SELECT 'COMPLIANCE_TYPE', MAX(ComplianceTypeLast)
	FROM dbo.ComplianceTypeTable

	UNION ALL

	SELECT 'CONS_EXE_VERSION', MAX(ConsExeVersionLast)
	FROM dbo.ConsExeVersionTable

	UNION ALL

	SELECT 'CONTRACT_FOUNDATION', MAX(LAST)
	FROM dbo.ContractFoundation

	UNION ALL

	SELECT 'CONTRACT_PAY', MAX(ContractPayLast)
	FROM dbo.ContractPayTable

	UNION ALL

	SELECT 'CONTRACT_TYPE', MAX(ContractTypeLast)
	FROM dbo.ContractTypeTable

	UNION ALL

	SELECT 'DEBT_TYPE', MAX(LAST)
	FROM dbo.DebtType

	UNION ALL

	SELECT 'DELIVERY', MAX(LAST)
	FROM dbo.Delivery

	UNION ALL

	SELECT 'DISCONNECT_REASON', MAX(DR_LAST)
	FROM dbo.DisconnectReason

	UNION ALL

	SELECT 'DISCOUNT', MAX(DiscountLast)
	FROM dbo.DiscountTable

	UNION ALL

	SELECT 'DISTRICT', MAX(DS_LAST)
	FROM dbo.District

	UNION ALL

	SELECT 'DISTR_STATUS', MAX(DS_LAST)
	FROM dbo.DistrStatus

	UNION ALL

	SELECT 'DISTR_TYPE', MAX(DistrTypeLast)
	FROM dbo.DistrTypeTable

	UNION ALL

	SELECT 'DOCUMENT_GRANT_TYPE', MAX(LAST)
	FROM dbo.DocumentGrantType

	UNION ALL

	SELECT 'DOCUMENT', MAX(LAST)
	FROM dbo.DocumentType

	UNION ALL

	SELECT 'DUTY_PERSONAL', MAX(DutyLast)
	FROM dbo.DutyTable

	UNION ALL

	SELECT 'EVENT_TYPE', MAX(EventTypeLast)
	FROM dbo.EventTypeTable

	UNION ALL

	SELECT 'HOST', MAX(HostLast)
	FROM dbo.Hosts

	UNION ALL

	SELECT 'INFO_BANK', MAX(InfoBankLast)
	FROM dbo.InfoBankTable

	UNION ALL

	SELECT 'INNOVATION', MAX(LAST)
	FROM dbo.Innovation

	UNION ALL

	SELECT 'JOURNAL', MAX(LAST)
	FROM dbo.Journal

	UNION ALL

	SELECT 'KD_VERSION', MAX(LAST)
	FROM dbo.KDVersion

	UNION ALL

	SELECT 'LAWYER_PERSONAL', MAX(LW_LAST)
	FROM dbo.Lawyer

	UNION ALL

	SELECT 'LESSON_PLACE', MAX(LessonPlaceLast)
	FROM dbo.LessonPlaceTable

	UNION ALL

	SELECT 'MANAGER_PERSONAL', MAX(ManagerLast)
	FROM dbo.ManagerTable

	UNION ALL

	SELECT 'OWNERSHIP', MAX(OwnershipLast)
	FROM dbo.OwnershipTable

	UNION ALL

	SELECT 'PAY_TYPE', MAX(PayTypeLast)
	FROM dbo.PayTypeTable

	UNION ALL

	SELECT 'PERSONAL', MAX(PersonalLast)
	FROM dbo.PersonalTable

	UNION ALL

	SELECT 'PHONE_TYPE', MAX(PT_LAST)
	FROM dbo.PhoneType

	UNION ALL

	SELECT 'POSITION_TYPE', MAX(PositionTypeLast)
	FROM dbo.PositionTypeTable

	UNION ALL

	SELECT 'PROFILE_TYPE', MAX(LAST)
	FROM dbo.ProfileType

	UNION ALL

	SELECT 'QUESTION', MAX(QuestionLast)
	FROM dbo.QuestionTable

	UNION ALL

	SELECT 'RANGE', Max(RangeLast)
	FROM dbo.RangeTable

	UNION ALL

	SELECT 'RDD_POSITION', MAX(LAST)
	FROM dbo.RDDPosition

	UNION ALL

	SELECT 'REGION', MAX(RG_LAST)
	FROM dbo.Region

	UNION ALL

	SELECT 'RES_VERSION', MAX(ResVersionLast)
	FROM dbo.ResVersionTable

	UNION ALL

	SELECT 'RICH_COEF', MAX(RichCoefLast)
	FROM dbo.RichCoefTable

	UNION ALL

	SELECT 'RIVAL_STATUS', MAX(RS_LAST)
	FROM dbo.RivalStatus

	UNION ALL

	SELECT 'RIVAL_TYPE', MAX(RivalTypeLast)
	FROM dbo.RivalTypeTable

	UNION ALL

	SELECT 'SATISFACTION_QUESTION', MAX(SQ_LAST)
	FROM dbo.SatisfactionQuestion

	UNION ALL

	SELECT 'SATISFACTION_TYPE', MAX(STT_LAST)
	FROM dbo.SatisfactionType

	UNION ALL

	SELECT 'SERTIFICAT_TYPE', MAX(LAST)
	FROM dbo.SertificatType

	UNION ALL

	SELECT 'SERVICE_POSITION', MAX(ServicePositionLast)
	FROM dbo.ServicePositionTable

	UNION ALL

	SELECT 'CLIENT_STATUS', MAX(ServiceStatusLast)
	FROM dbo.ServiceStatusTable

	UNION ALL

	SELECT 'SERVICE_PERSONAL', MAX(ServiceLast)
	FROM dbo.ServiceTable

	UNION ALL

	SELECT 'SERVICE_TYPE', MAX(ServiceTypeLast)
	FROM dbo.ServiceTypeTable

	UNION ALL

	SELECT 'STREET', MAX(ST_LAST)
	FROM dbo.Street

	UNION ALL

	SELECT 'STUDENT_POSITION', MAX(StudentPositionLast)
	FROM dbo.StudentPositionTable

	UNION ALL

	SELECT 'STUDY_QUALITY_TYPE', MAX(LAST)
	FROM dbo.StudyQualityType

	UNION ALL

	SELECT 'STUDY_TYPE', MAX(LAST)
	FROM dbo.StudyType

	UNION ALL

	SELECT 'SUBHOST', MAX(SH_LAST)
	FROM dbo.Subhost

	UNION ALL

	SELECT 'SYSTEM', MAX(SystemLast)
	FROM dbo.SystemTable

	UNION ALL

	SELECT 'SYSTEM_TYPE', MAX(SystemTypeLast)
	FROM dbo.SystemTypeTable

	UNION ALL

	SELECT 'TEACHER_PERSONAL', MAX(TeacherLast)
	FROM dbo.TeacherTable

	UNION ALL

	SELECT 'USR_KIND', MAX(USRFileKindLast)
	FROM dbo.USRFileKindTable

	UNION ALL

	SELECT 'VENDOR', MAX(LAST)
	FROM dbo.Vendor

	UNION ALL

	SELECT 'VISIT_PAY', MAX(VisitPayLast)
	FROM dbo.VisitPayTable

	UNION ALL

	SELECT 'DIN_NET_TYPE', MAX(NT_LAST)
	FROM Din.NetType

	UNION ALL

	SELECT 'DIN_SYSTEM_TYPE', MAX(SST_LAST)
	FROM Din.SystemType

	UNION ALL

	SELECT 'MEMO_DOCUMENT', MAX(LAST)
	FROM Memo.Document

	UNION ALL

	SELECT 'MEMO_SERVICE', MAX(LAST)
	FROM Memo.Service

	UNION ALL

	SELECT 'POLL_BLANK', MAX(LAST)
	FROM Poll.Blank

	UNION ALL

	SELECT 'ACTION', MAX(LAST)
	FROM Price.Action

	UNION ALL

	SELECT 'COMMERCIAL_OPERATION', MAX(LAST)
	FROM Price.CommercialOperation

	UNION ALL

	SELECT 'OFFER_TEMPLATE', MAX(LAST)
	FROM Price.OfferTemplate

	UNION ALL

	SELECT 'APPLY_REASON', MAX(AR_LAST)
	FROM Purchase.ApplyReason

	UNION ALL

	SELECT 'CLAIM_CANCEL_REASON', MAX(CCR_LAST)
	FROM Purchase.ClaimCancelReason

	UNION ALL

	SELECT 'CLAIM_PROVISION', MAX(CP_LAST)
	FROM Purchase.ClaimProvision

	UNION ALL

	SELECT 'CONTRACT_EXECUTION_PROVISION', MAX(CEP_LAST)
	FROM Purchase.ContractExecutionProvision

	UNION ALL

	SELECT 'PURCHASE_DOCUMENT', MAX(DC_LAST)
	FROM Purchase.Document

	UNION ALL

	SELECT 'GOOD_REQUIREMENT', MAX(GR_LAST)
	FROM Purchase.GoodRequirement

	UNION ALL

	SELECT 'OTHER_PROVISION', MAX(OP_LAST)
	FROM Purchase.OtherProvision

	UNION ALL

	SELECT 'PATRNER_REQUIREMENT', MAX(PR_LAST)
	FROM Purchase.PartnerRequirement

	UNION ALL

	SELECT 'PAY_PERIOD', MAX(PP_LAST)
	FROM Purchase.PayPeriod

	UNION ALL

	SELECT 'PLACEMENT_ORDER', MAX(PO_LAST)
	FROM Purchase.PlacementOrder

	UNION ALL

	SELECT 'PRICE_VALIDATION', MAX(PV_LAST)
	FROM Purchase.PriceValidation

	UNION ALL

	SELECT 'PURCHASE_KIND', MAX(PK_LAST)
	FROM Purchase.PurchaseKind

	UNION ALL

	SELECT 'PURCHASE_REASON', MAX(PR_LAST)
	FROM Purchase.PurchaseReason

	UNION ALL

	SELECT 'PURCHASE_TYPE', MAX(PT_LAST)
	FROM Purchase.PurchaseType

	UNION ALL

	SELECT 'SIGN_PERIOD', MAX(SP_LAST)
	FROM Purchase.SignPeriod

	UNION ALL

	SELECT 'TENDER', MAX(TN_LAST)
	FROM Purchase.TenderName

	UNION ALL

	SELECT 'TRADEMARK', MAX(TM_LAST)
	FROM Purchase.Trademark

	UNION ALL

	SELECT 'TRADESITE', MAX(TS_LAST)
	FROM Purchase.TradeSite

	UNION ALL

	SELECT 'USE_CONDITION', MAX(UC_LAST)
	FROM Purchase.UseCondition

	UNION ALL

	SELECT 'USER', MAX(US_LAST)
	FROM Security.Users

	UNION ALL

	SELECT 'SEMINAR_STATUS', MAX(LAST)
	FROM Seminar.Status

	UNION ALL

	SELECT 'SEMINAR_SUBJECT', MAX(LAST)
	FROM Seminar.Subject

	UNION ALL

	SELECT 'TENDER_CALC_DIRECTION', MAX(LAST)
	FROM Tender.CalcDirection

	UNION ALL

	SELECT 'TENDER_LAW', MAX(LAST)
	FROM Tender.Law

	UNION ALL

	SELECT 'TENDER_STATUS', MAX(LAST)
	FROM Tender.Status

	UNION ALL

	SELECT 'TENDER_SYSTEM_TYPE', MAX(LAST)
	FROM Tender.SystemType

	UNION ALL

	SELECT 'TRAINING_SUBJECT', MAX(TS_LAST)
	FROM Training.TrainingSubject
END
