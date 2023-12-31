USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[TRAINING_CANCEL]
	@PARAM	NVARCHAR(MAX) = NULL
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

		/*
		SELECT ClientFullName AS [������], ManagerName AS [���-��], ServiceName AS [��], COUNT(DISTINCT SP_ID) AS [������� ���], MAX(TSC_DATE) AS [��������� ���]
		FROM
			Training.TrainingSchedule
			INNER JOIN Training.SeminarSign ON SP_ID_SEMINAR = TSC_ID
			INNER JOIN Training.SeminarSignPersonal ON SSP_ID_SIGN = SP_ID
			INNER JOIN dbo.ClientView WITH(NOEXPAND) ON SP_ID_CLIENT = ClientID
		WHERE SSP_CANCEL = 1
		GROUP BY ClientFullname, ManagerName, ServiceName
		HAVING COUNT(DISTINCT SP_ID) > 2
		ORDER BY [������� ���] DESC, ManagerName, ServiceName, ClientFullName
		*/

		--���� ����� �� ����� ��������� ������ �� �������. ���� ������, ��� � ����� ��������� ������ �� ��� ������������ ������, ��� ��� ���� ������ ����� ����

		SELECT ClientFullName AS [������], ManagerName AS [���-��], ServiceName AS [��], COUNT(DISTINCT ID_SCHEDULE) AS [������� ���], MAX(c.DATE) AS [��������� ���]
		FROM
			Seminar.Personal a
			INNER JOIN Seminar.Status b ON a.ID_STATUS = b.ID
			INNER JOIN Seminar.Schedule c ON c.ID = a.ID_SCHEDULE
			INNER JOIN dbo.ClientView WITH(NOEXPAND) ON a.ID_CLIENT = ClientID
		WHERE b.INDX = 5 AND a.STATUS = 1
		GROUP BY ClientFullname, ManagerName, ServiceName
		HAVING COUNT(DISTINCT ID_SCHEDULE) > 2
		ORDER BY [������� ���] DESC, ManagerName, ServiceName, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH

END
GO
GRANT EXECUTE ON [Report].[TRAINING_CANCEL] TO rl_report;
GO
