USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REG_PROTOCOL_FILTER]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@SYS	INT,
	@DISTR	INT,
	@COMP	TINYINT,
	@OPER	NVARCHAR(256),
	@TEXT	NVARCHAR(256)
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

		SET @END = DATEADD(DAY, 1, @END)

		DECLARE @HST INT

		IF @SYS IS NOT NULL
			SELECT @HST = HostID
			FROM dbo.SystemTable
			WHERE SystemID = @SYS

		SELECT
			RPR_DATE, HostShort, dbo.DistrString(NULL, RPR_DISTR, RPR_COMP) AS DIS_STR,
			RPR_OPER, RPR_TYPE, RPR_TEXT, RPR_USER, RPR_COMPUTER, RPR_INSERT
		FROM
			dbo.RegProtocol a
			INNER JOIN dbo.Hosts b ON a.RPR_ID_HOST = b.HostID
		WHERE (RPR_DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (RPR_DATE < @END OR @END IS NULL)
			AND (RPR_ID_HOST = @HST OR @HST IS NULL)
			AND (RPR_DISTR = @DISTR OR @DISTR IS NULL)
			AND (RPR_COMP = @COMP OR @COMP IS NULL)
			AND (RPR_OPER LIKE @OPER OR @OPER IS NULL)
			AND (RPR_TEXT LIKE @TEXT OR @TEXT IS NULL)
		ORDER BY RPR_DATE DESC, HostOrder, RPR_DISTR, RPR_COMP

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[REG_PROTOCOL_FILTER] TO rl_reg_protocol;
GO