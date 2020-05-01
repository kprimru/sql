USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 15.10.2008
��������:	  �������� ������ � ������� � 
               ��������� �����
*/

ALTER PROCEDURE [dbo].[PERIOD_EDIT] 
	@periodid SMALLINT,
	@periodname VARCHAR(20),
	@perioddate SMALLDATETIME,
	@periodenddate SMALLDATETIME,
	@breport	SMALLDATETIME,
	@ereport	SMALLDATETIME,
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		UPDATE dbo.PeriodTable 
		SET PR_NAME = @periodname, 
			PR_DATE = @perioddate,
			PR_END_DATE = @periodenddate,
			PR_BREPORT	=	@breport,
			PR_EREPORT	=	@ereport,
			PR_ACTIVE = @active
		WHERE PR_ID = @periodid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[PERIOD_EDIT] TO rl_period_w;
GO