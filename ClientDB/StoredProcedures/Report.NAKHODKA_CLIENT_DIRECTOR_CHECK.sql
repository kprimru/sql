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
			ClientFulLName	VarChar(512),
			CL_FULL_NAME	VarChar(512),
			CP_FIO			VarChar(256),
			DBF_FIO			VarChar(256),
			CP_POS			VarChar(256),
			POS_NAME		VarChar(256),
			CA_ADDRESS      VarChar(512),
			CA_CITY         VarChar(128),
			CA_STREET       VarChar(128),
			CA_HOME         VarChar(128),
			CA_INDEX        VarChar(32),
			DBF_ADDRESS     VarChar(512),
			DBF_CITY        VarChar(128),
			DBF_STREET      VarChar(128),
			DBF_HOME        VarChar(128),
			DBF_INDEX       VarChar(32),
			DistrStr		VarChar(128)
		);

		INSERT INTO @Result
		SELECT CLientFulLName, CL_FULL_NAME, CP_FIO, DBF_FIO, CP_POS, POS_NAME, CA_ADDRESS, CA_CITY, CA_STREET, CA_HOME, CA_INDEX, DBF_ADDRESS, DBF_CITY, DBF_STREET, DBF_HOME, DBF_INDEX, DistrStr
		FROM [PC276-SQL\NKH].[ClientDB].[dbo].[ClientTable] C
		INNER JOIN [PC276-SQL\NKH].[ClientDB].[dbo].[ClientPersonalDirView] CD WITH(NOEXPAND) ON C.CLientID = CD.CP_ID_CLIENT
		CROSS APPLY
		(
		    SELECT TOP (1)
		        [CA_ADDRESS]    = CA_STR,
		        [CA_CITY]       = CT_NAME,
		        [CA_STREET]     = ST_NAME,
		        [CA_INDEX]      = CA_INDEX,
		        [CA_HOME]       = REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(ISNULL(CA_HOME, '') + ISNULL(CA_OFFICE, ''),
										' ', ''),
										'�.', ''),
										'����', ''),
										'��', ''),
										'�.', ''),
										'���', ''),
										'��', ''),
										'��', ''),
										'.', ''),
										',', ''
									)
		    FROM [PC276-SQL\NKH].[ClientDB].[dbo].[ClientAddressView] AS CA WITH(NOEXPAND)
		    WHERE CA_ID_CLIENT = C.ClientID
		        AND CA.AT_REQUIRED = 1
		) AS CA
		CROSS APPLY
		(
			SELECT TOP (1) SystemBaseName, DISTR, COMP, DIstrStr
			FROM [PC276-SQL\NKH].[ClientDB].[dbo].[CLientDistrView] D WITH(NOEXPAND)
			WHERE D.ID_CLIENT = C.ClientID
				AND D.DS_REG = 0
			ORDER BY SystemOrder, DISTR, COMP
		) D
		OUTER APPLY
		(
			SELECT TOP (1) CL_FULL_NAME, DBF_FIO, POS_NAME, [DBF_ADDRESS], [DBF_CITY], [DBF_STREET], [DBF_HOME], DBF_INDEX
			FROM [PC275-SQL\DELTA].[DBF_NAH].[dbo].[ClientTable] DC
			INNER JOIN [PC275-SQL\DELTA].[DBF_NAH].[dbo].[ClientDistrView] DD ON DD.CD_ID_CLIENT = DC.CL_ID
			OUTER APPLY
			(
				SELECT TOP (1) [DBF_FIO] = PER_FAM + ' ' + PER_NAME + ' ' + PER_OTCH, PP.POS_NAME
				FROM [PC275-SQL\DELTA].[DBF_NAH].[dbo].[ClientPersonalTable] DCP
				INNER JOIN [PC275-SQL\DELTA].[DBF_NAH].[dbo].[PositionTable] PP ON POS_ID = PER_ID_POS
				WHERE DCP.PER_ID_CLIENT = DC.CL_ID AND DCP.PER_ID_REPORT_POS = 1
			) P
			OUTER APPLY
			(
			    SELECT TOP (1)
			        [DBF_ADDRESS]   = IsNull(DCA.CT_NAME + ',' + DCA.ST_NAME + CASE ISNULL(DCA.CA_HOME, '') WHEN '' THEN '' ELSE ',' + DCA.CA_HOME END, CA_STR),
			        [DBF_CITY]      = CT_NAME,
			        [DBF_STREET]    = Replace(Replace(ST_NAME, '���. ��������, ', ''), '��������, ', ''),
			        [DBF_INDEX]     = DCA.CA_INDEX,
			        [DBF_HOME]      = REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
									REPLACE(
										CA_HOME,
										' ', ''),
										'�.', ''),
										'����', ''),
										'��', ''),
										'�.', ''),
										'���', ''),
										'��', ''),
										'��', ''),
										'.', ''),
										',', ''
									)
			    FROM [PC275-SQL\DELTA].[DBF_NAH].[dbo].[ClientAddressView] DCA WITH(NOEXPAND)
			    WHERE DCA.CA_ID_CLIENT = DC.CL_ID
			        AND CA_ID_TYPE = 2
			) AS DCA
			WHERE DD.SYS_REG_NAME = D.SystemBaseName AND DD.DIS_NUM = D.DISTR AND DD.DIS_COMP_NUM = D.COMP

		) P
		WHERE C.STATUS = 1 AND C.StatusId = 2

		SELECT
		    [������|� ��] = ClientFullName,
			[������|� DBF] = CL_FULL_NAME,
			[��� ���-��|������] = Cast(CASE WHEN IsNull(CP_FIO, '') != IsNull(DBF_FIO, '') THEN 1 ELSE 0 END AS Bit),
			[��� ���-��|� ��] = CP_FIO,
			[��� ���-��|� DBF] = DBF_FIO,
			[��������� ���-��|� ��] = CP_POS,
			[��������� ���-��|� DBF] = POS_NAME,
			[��������� ���-��|������] = Cast(CASE WHEN IsNull(CP_POS, '') != IsNull(POS_NAME, '') THEN 1 ELSE 0 END AS Bit),
			[�����|� ��] = CA_ADDRESS,
			[�����|� DBF] = DBF_ADDRESS,
			[�����|������] = Cast(CASE WHEN (DBF_CITY = CA_CITY AND DBF_STREET = CA_STREET AND DBF_HOME = CA_HOME) OR CA_ADDRESS = DBF_ADDRESS  THEN 0 ELSE 1 END AS Bit),
			[������|� ��] = CA_INDEX,
			[������|� DBF] = DBF_INDEX,
			[������|������] = Cast(CASE WHEN IsNull(CA_INDEX, '') != IsNull(DBF_INDEX, '') THEN 1 ELSE 0 END AS Bit),
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