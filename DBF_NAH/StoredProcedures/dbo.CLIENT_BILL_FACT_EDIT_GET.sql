USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
�����:			������� �������/������ ��������
���� ��������:  19/10/2009
��������:		get-��������� ��� ����� �������������� ������ (����. ������. �����)
*/

ALTER PROCEDURE [dbo].[CLIENT_BILL_FACT_EDIT_GET]
	@bfmid INT

AS
BEGIN
	SET NOCOUNT ON;
	/*
	DECLARE @d DATETIME
	SET @d = CONVERT(DATETIME, @date, 121)
	*/

	SELECT
		BFM_ID,
		BFM_DATE,
		BFM_NUM,
		BFM_ID_PERIOD,
		PR_ID,
		PR_DATE,
		BILL_DATE,
		CL_ID,
		CL_SHORT_NAME,
		CL_CITY,
		CL_ADDRESS,
		ORG_ID,
		ORG_SHORT_NAME,
		ORG_INDEX,
		ORG_ADDRESS,
		ORG_PHONE,
		ORG_ACCOUNT,
		ORG_LORO,
		ORG_BIK,
		ORG_INN,
		ORG_KPP,
		ORG_OKONH,
		ORG_OKPO,
		ORG_BUH_SHORT,
		BA_NAME,
		BA_CITY,
		CO_NUM,
		CO_DATE,
		CO_ID
	FROM dbo.BillFactMasterTable INNER JOIN
		dbo.PeriodTable ON PR_ID = BFM_ID_PERIOD
	WHERE BFM_ID = @bfmid

END




GO
GRANT EXECUTE ON [dbo].[CLIENT_BILL_FACT_EDIT_GET] TO rl_bill_w;
GO