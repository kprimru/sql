USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SYSTEM_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SYSTEM_SELECT]
	@FILTER			VARCHAR(100) = NULL,
	@SYSTEM_ACTIVE	BIT = NULL
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
			a.SystemID, SystemShortName, a.SystemBaseName, SystemNumber, HostShort, a.HostID,
			dbo.FileByteSizeToStr(
				(
					SELECT SUM(IBS_SIZE)
					FROM
						dbo.InfoBankSizeView y WITH(NOEXPAND)
						INNER JOIN dbo.SystemBankTable z ON z.InfoBankID = IBF_ID_IB
					WHERE z.SystemID = a.SystemID
						AND IBS_DATE =
							(
								SELECT MAX(IBS_DATE)
								FROM dbo.InfoBankSizeView t WITH(NOEXPAND)
								WHERE t.IBF_ID_IB = y.IBF_ID_IB
							)
				)
			) AS IBS_SIZE,
			sdv.Docs
		FROM dbo.SystemTable a
		LEFT JOIN dbo.Hosts b ON a.HostID = b.HostID
		OUTER APPLY
		(
			SELECT TOP (1)
				sdv.Docs
			FROM dbo.SystemDocsView sdv
			WHERE a.SystemID = sdv.SystemID
		) AS sdv
		WHERE (@FILTER IS NULL
			OR SystemShortName LIKE @FILTER
			OR SystemName LIKE @FILTER
			OR SystemFullName LIKE @FILTER
			OR a.SystemBaseName LIKE @FILTER
			OR CONVERT(VARCHAR(20), SystemNumber) LIKE @FILTER) AND
			(@SYSTEM_ACTIVE IS NULL
			OR SystemActive = @SYSTEM_ACTIVE)
		ORDER BY SystemOrder

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_SELECT] TO rl_system_r;
GO
