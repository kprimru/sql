USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[TENDER_SUMMARY]
	@CURDATE	DATETIME
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT
			p.DATE,-- AS [���� ����������],
			p.CLAIM_PRIVISION,-- AS [����� ����������� ������],
			p.DATE + 6 AS [SPECBILL_TIME],-- AS [���� �������� �� ��������],
			p.DATE + 4 AS [REQUEST_DATE],-- AS [���� ������ ������],
			p.PROTOCOL AS [PROTOCOL_DATE],-- AS [���� ���������],
			p.GK_PROVISION_SUM,-- AS [����� ����������� ���������],
			p.PROTOCOL + 3 AS [TRANSACTION TIME],-- AS [���� �������� �� �/� ���������],
			p.PART_SUM,-- AS [����� ������ ��. ��.],
			p.PROTOCOL + 3 AS [SPECBILL_TIME2],-- AS [���� �������� �� ��������],
			p.GK_SIGN_FACT,-- AS [���� ���������� ��],
			dbo.GetLastWeekDay(4, @CURDATE) AS [CASHBACK_TIME],-- AS [����� ����������� ������], -- ��������� ������� �������� ������
			CONVERT(VARCHAR, p.GK_START, 4) + ' - ' + CONVERT(VARCHAR, p.GK_FINISH, 4) AS [GK_TIME],--	AS [���� �������� ���������],
			(SELECT COUNT(NAME)
			FROM Common.Period
			WHERE TYPE = 3 AND			--������ ������� ��������� ����� ���������
					FINISH > p.GK_START AND
					START < p.GK_FINISH) AS [QUART_COUNT],
			CONVERT(VARCHAR, CONVERT(INT, p.GK_PROVISION_SUM)/(SELECT COUNT(NAME)
												FROM Common.Period
												WHERE TYPE = 3 AND			--������ ������� ��������� ����� ���������
													FINISH > p.GK_START AND
													START < p.GK_FINISH)) AS [QUART_SUM],
			CONVERT(VARCHAR, CONVERT(INT, p.GK_PROVISION_SUM)/(SELECT COUNT(NAME)
												FROM Common.Period
												WHERE TYPE = 3 AND			--������ ������� ��������� ����� ���������
													FINISH > p.GK_START AND
													START < p.GK_FINISH) +  p.GK_PROVISION_SUM%(SELECT COUNT(NAME)
																								FROM Common.Period
																								WHERE TYPE = 3 AND			--������ ������� ��������� ����� ���������
																									FINISH > p.GK_START AND
																									START < p.GK_FINISH)) AS [LAST_QUART_SUM],
			CONVERT(VARCHAR, p.GK_PROVISION_SUM)	AS [CASHBACK]
		FROM
			Tender.Placement p
		ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
