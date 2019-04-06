USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[REFERENCE_LAST]
	@LAST	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT @LAST = MAX(DT)
	FROM
		(			
			SELECT MAX(AC_LAST) AS DT
			FROM dbo.Activity

			UNION ALL

			SELECT MAX(AC_LAST)
			FROM dbo.Activity

			UNION ALL

			SELECT MAX(LAST)
			FROM Memo.Document

			UNION ALL
			
			SELECT MAX(LAST)
			FROM Memo.Service

			UNION ALL
			
			SELECT MAX(LAST)
			FROM Price.Action

			UNION ALL
			
			SELECT MAX(TM_LAST)
			FROM Purchase.Trademark

			UNION ALL

			SELECT MAX(LAST)
			FROM dbo.SertificatType

			UNION ALL

			SELECT MAX(LAST)
			FROM Common.Period

			UNION ALL

			SELECT MAX(AT_LAST)
			FROM dbo.AddressType

			UNION ALL
	
			SELECT MAX(AR_LAST)
			FROM dbo.Area

			UNION ALL

			SELECT MAX(LAST)
			FROM dbo.CalendarType

			UNION ALL

			SELECT MAX(LAST)
			FROM dbo.CallDirection

			UNION ALL

			SELECT MAX(CallTypeLast)
			FROM dbo.CallTypeTable

			UNION ALL

			SELECT MAX(CT_LAST)
			FROM dbo.City

			UNION ALL

			SELECT MAX(CPT_LAST)
			FROM dbo.ClientPersonalType

			UNION ALL

			SELECT MAX(ClientTypeLast)
			FROM dbo.ClientTypeTable
	
			UNION ALL

			SELECT MAX(ComplianceTypeLast)
			FROM dbo.ComplianceTypeTable

			UNION ALL

			SELECT MAX(ConsExeVersionLast)
			FROM dbo.ConsExeVersionTable

			UNION ALL

			SELECT MAX(LAST)
			FROM dbo.ClientContactType

			UNION ALL
			
			SELECT MAX(LAST)
			FROM dbo.ContractFoundation

			UNION ALL

			SELECT MAX(ContractPayLast)
			FROM dbo.ContractPayTable

			UNION ALL

			SELECT MAX(ContractTypeLast)
			FROM dbo.ContractTypeTable

			UNION ALL

			SELECT MAX(LAST)
			FROM dbo.Delivery

			UNION ALL

			SELECT MAX(DR_LAST)
			FROM dbo.DisconnectReason

			UNION ALL

			SELECT MAX(DiscountLast)
			FROM dbo.DiscountTable

			UNION ALL

			SELECT MAX(DS_LAST)
			FROM dbo.District

			UNION ALL

			SELECT MAX(DS_LAST)
			FROM dbo.DistrStatus

			UNION ALL

			SELECT MAX(DistrTypeLast)
			FROM dbo.DistrTypeTable

			UNION ALL

			SELECT MAX(LAST)
			FROM dbo.DocumentGrantType

			UNION ALL

			SELECT MAX(LAST)
			FROM dbo.DocumentType

			UNION ALL
	
			SELECT MAX(DutyLast)
			FROM dbo.DutyTable

			UNION ALL

			SELECT MAX(EventTypeLast)
			FROM dbo.EventTypeTable

			UNION ALL

			SELECT MAX(HostLast)
			FROM dbo.Hosts

			UNION ALL

			SELECT MAX(InfoBankLast)
			FROM dbo.InfoBankTable

			UNION ALL

			SELECT MAX(KDL_LAST)
			FROM dbo.KGSDistrList

			UNION ALL

			SELECT MAX(LW_LAST)
			FROM dbo.Lawyer

			UNION ALL

			SELECT MAX(LessonPlaceLast)
			FROM dbo.LessonPlaceTable

			UNION ALL

			SELECT MAX(ManagerLast)
			FROM dbo.ManagerTable

			UNION ALL

			SELECT MAX(LAST)
			FROM Price.OfferTemplate

			UNION ALL

			SELECT MAX(OwnershipLast)
			FROM dbo.OwnershipTable

			UNION ALL

			SELECT MAX(PayTypeLast)
			FROM dbo.PayTypeTable

			UNION ALL

			SELECT MAX(PersonalLast)
			FROM dbo.PersonalTable

			UNION ALL

			SELECT MAX(PT_LAST)
			FROM dbo.PhoneType
	
			UNION ALL

			SELECT MAX(PositionTypeLast)
			FROM dbo.PositionTypeTable

			UNION ALL

			SELECT MAX(QuestionLast)
			FROM dbo.QuestionTable

			UNION ALL

			SELECT MAX(RangeLast)
			FROM dbo.RangeTable

			UNION ALL

			SELECT MAX(RG_LAST)
			FROM dbo.Region

			UNION ALL

			SELECT MAX(ResVersionLast)
			FROM dbo.ResVersionTable
	
			UNION ALL

			SELECT MAX(RichCoefLast)
			FROM dbo.RichCoefTable

			UNION ALL

			SELECT MAX(RS_LAST)
			FROM dbo.RivalStatus

			UNION ALL

			SELECT MAX(RivalTypeLast)
			FROM dbo.RivalTypeTable

			UNION ALL

			SELECT MAX(SQ_LAST)
			FROM dbo.SatisfactionQuestion

			UNION ALL

			SELECT MAX(STT_LAST)
			FROM dbo.SatisfactionType

			UNION ALL

			SELECT MAX(ServicePositionLast)
			FROM dbo.ServicePositionTable

			UNION ALL

			SELECT MAX(ServiceStatusLast)
			FROM dbo.ServiceStatusTable

			UNION ALL

			SELECT MAX(ServiceLast)
			FROM dbo.ServiceTable

			UNION ALL

			SELECT MAX(ServiceTypeLast)
			FROM dbo.ServiceTypeTable

			UNION ALL

			SELECT MAX(ST_LAST)
			FROM dbo.Street

			UNION ALL

			SELECT MAX(StudentPositionLast)
			FROM dbo.StudentPositionTable

			UNION ALL

			SELECT MAX(LAST)
			FROM dbo.StudyType

			UNION ALL

			SELECT MAX(SH_LAST)
			FROM dbo.Subhost

			UNION ALL
	
			SELECT MAX(SystemLast)
			FROM dbo.SystemTable

			UNION ALL

			SELECT MAX(SystemTypeLast)
			FROM dbo.SystemTypeTable

			UNION ALL

			SELECT MAX(LAST)
			FROM dbo.Vendor

			UNION ALL

			SELECT MAX(LAST)
			FROM Common.Tax

			UNION ALL

			SELECT MAX(TeacherLast)
			FROM dbo.TeacherTable

			UNION ALL

			SELECT MAX(USRFileKindLast)
			FROM dbo.USRFileKindTable

			UNION ALL

			SELECT MAX(VisitPayLast)
			FROM dbo.VisitPayTable

			UNION ALL

			SELECT MAX(NT_LAST)
			FROM Din.NetType

			UNION ALL

			SELECT MAX(SST_LAST)
			FROM Din.SystemType
			
			UNION ALL

			SELECT MAX(LAST)
			FROM Price.CommercialOperation

			UNION ALL

			SELECT MAX(AR_LAST)
			FROM Purchase.ApplyReason

			UNION ALL

			SELECT MAX(CCR_LAST)
			FROM Purchase.ClaimCancelReason

			UNION ALL

			SELECT MAX(CP_LAST)
			FROM Purchase.ClaimProvision

			UNION ALL

			SELECT MAX(CEP_LAST)
			FROM Purchase.ContractExecutionProvision

			UNION ALL

			SELECT MAX(DC_LAST)
			FROM Purchase.Document

			UNION ALL

			SELECT MAX(GR_LAST)
			FROM Purchase.GoodRequirement

			UNION ALL

			SELECT MAX(OP_LAST)
			FROM Purchase.OtherProvision

			UNION ALL

			SELECT MAX(PP_LAST)
			FROM Purchase.PayPeriod

			UNION ALL

			SELECT MAX(PR_LAST)
			FROM Purchase.PartnerRequirement

			UNION ALL

			SELECT MAX(PO_LAST)
			FROM Purchase.PlacementOrder

			UNION ALL

			SELECT MAX(PV_LAST)
			FROM Purchase.PriceValidation

			UNION ALL

			SELECT MAX(PK_LAST)
			FROM Purchase.PurchaseKind
			
			UNION ALL

			SELECT MAX(PR_LAST)
			FROM Purchase.PurchaseReason

			UNION ALL

			SELECT MAX(PT_LAST)
			FROM Purchase.PurchaseType

			UNION ALL

			SELECT MAX(SP_LAST)
			FROM Purchase.SignPeriod

			UNION ALL

			SELECT MAX(TN_LAST)
			FROM Purchase.TenderName

			UNION ALL

			SELECT MAX(TS_LAST)
			FROM Purchase.TradeSite

			UNION ALL

			SELECT MAX(UC_LAST)
			FROM Purchase.UseCondition

			UNION ALL

			SELECT MAX(LAST)
			FROM Seminar.Subject	

			UNION ALL
	
			SELECT MAX(TS_LAST)
			FROM Training.TrainingSubject

			UNION ALL

			SELECT MAX(TSC_LAST)
			FROM Training.TrainingSchedule

			UNION ALL

			SELECT MAX(OS_LAST)
			FROM USR.Os

			UNION ALL

			SELECT MAX(OF_LAST)
			FROM USR.OSFamily

			UNION ALL

			SELECT MAX(PRC_LAST)
			FROM USR.Processor

			UNION ALL

			SELECT MAX(PF_LAST)
			FROM USR.ProcessorFamily

			UNION ALL

			SELECT MAX(ClientLast)
			FROM dbo.ClientTable
			
			UNION ALL

			SELECT MAX(LAST)
			FROM dbo.StudyQualityType
			
			UNION ALL

			SELECT MAX(LAST)
			FROM Contract.Type
			
			UNION ALL

			SELECT MAX(LAST)
			FROM Contract.Forms
			
			UNION ALL

			SELECT MAX(LAST)
			FROM Contract.Specification
		) AS o_O
END