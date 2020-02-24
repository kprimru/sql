USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PERSONAL_FULL_SELECT]
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
	
		SELECT PersonalShortName, DepartmentName
		FROM dbo.PersonalTable

		UNION ALL

		SELECT ManagerName, '������������ ��������� ������'
		FROM dbo.ManagerTable

		UNION ALL

		SELECT ServiceName, '������-��������'
		FROM dbo.ServiceTable

		UNION ALL

		SELECT TeacherName, '�������������'
		FROM dbo.TeacherTable

		UNION ALL

		SELECT DutyName, '�������� ������'
		FROM dbo.DutyTable

		ORDER BY PersonalShortName
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END