USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[NAKHODKA_CLIENT_DIRECTOR_CHECK]
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

		DECLARE @Result TABLE
		(
			CLientFulLName	VarChar(500),
			CL_FULL_NAME	VarChar(500),
			CP_FIO			VarChar(250),
			DBF_FIO			VarChar(250),
			CP_POS			VarChar(250),
			POS_NAME		VarChar(250),
			DistrStr		VarChar(100)
		);

		INSERT INTO @Result
		SELECT CLientFullName, CL_FULL_NAME, CP_FIO, DBF_FIO, CP_POS, POS_NAME, DistrStr
		FROM [ClientDB?Nkh].[dbo.ClientTable] C
		INNER JOIN [ClientDB?Nkh].[dbo.ClientPersonalDirView] CD ON C.CLientID = CD.CP_ID_CLIENT
		CROSS APPLY
		(
			SELECT TOP (1) SystemBaseName, DISTR, COMP, DIstrStr
			FROM [ClientDB?Nkh].[dbo.CLientDistrView] D
			WHERE D.ID_CLIENT = C.ClientID
				AND D.DS_REG = 0
			ORDER BY SystemOrder, DISTR, COMP
		) D
		OUTER APPLY
		(
			SELECT TOP (1) CL_FULL_NAME, DBF_FIO, POS_NAME
			FROM [DBF_NAH].[dbo.ClientTable] DC
			INNER JOIN [DBF_NAH].[dbo.ClientDistrView] DD ON DD.CD_ID_CLIENT = DC.CL_ID
			OUTER APPLY
			(
				SELECT TOP (1) [DBF_FIO] = PER_FAM + ' ' + PER_NAME + ' ' + PER_OTCH, PP.POS_NAME
				FROM [DBF_NAH].[dbo.ClientPersonalTable] DCP
				INNER JOIN [DBF_NAH].[dbo.PositionTable] PP ON POS_ID = PER_ID_POS
				WHERE DCP.PER_ID_CLIENT = DC.CL_ID AND DCP.PER_ID_REPORT_POS = 1
			) P
			WHERE DD.SYS_REG_NAME = D.SystemBaseName AND DD.DIS_NUM = D.DISTR AND DD.DIS_COMP_NUM = D.COMP

		) P
		WHERE C.STATUS = 1 AND C.StatusId = 2

		SELECT
			[������|� ��] = ClientFullName,
			[������|� DBF] = CL_FULL_NAME,
			[��� ���-��|������] = Cast(CASE WHEN CP_FIO != DBF_FIO THEN 1 ELSE 0 END AS Bit),
			[��� ���-��|� ��] = CP_FIO,
			[��� ���-��|� DBF] = DBF_FIO,
			[��������� ���-��|� ��] = CP_POS,
			[��������� ���-��|� DBF] = POS_NAME,
			[���.�����������] = DistrStr
		FROM @Result
		ORDER BY CLientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[NAKHODKA_CLIENT_DIRECTOR_CHECK] TO rl_report;
GO