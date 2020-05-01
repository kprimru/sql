USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REG_PROTOCOL_DISTR]
	@DIS_ID		INT,
	@HST_ID		SMALLINT,
	@SYS_ID		SMALLINT,
	@DIS_NUM	INT,
	@DIS_COMP	TINYINT,
	@DIS_STR	VARCHAR(50) = NULL OUTPUT,
	@LAST	DATETIME = NULL OUTPUT
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

		SELECT @LAST = MAX(RPR_INSERT)
		FROM dbo.RegProtocol

		DECLARE @PTL_HOST	SMALLINT
		DECLARE @PTL_NUM	INT
		DECLARE @PTL_COMP	INT

		SELECT
			@PTL_HOST	=	HST_ID,
			@PTL_NUM	=	DIS_NUM,
			@PTL_COMP	=	DIS_COMP_NUM
		FROM dbo.DistrView WITH(NOEXPAND)
		WHERE (DIS_ID = @DIS_ID OR @DIS_ID IS NULL)
			AND (HST_ID = @HST_ID OR @HST_ID IS NULL)
			AND (SYS_ID = @SYS_ID OR @SYS_ID IS NULL)
			AND (DIS_NUM = @DIS_NUM OR @DIS_NUM IS NULL)
			AND (DIS_COMP_NUM = @DIS_COMP OR @DIS_COMP IS NULL)

		SELECT TOP 1 @DIS_STR = DIS_STR
		FROM dbo.DistrView WITH(NOEXPAND)
		WHERE HST_ID = @PTL_HOST
			AND DIS_NUM = @PTL_NUM
			AND DIS_COMP_NUM = @PTL_COMP
		ORDER BY DIS_ACTIVE DESC

		SELECT
			RPR_DATE,
			HST_SHORT + ' ' + CONVERT(VARCHAR(20), RPR_DISTR) +
			CASE RPR_COMP
				WHEN 1 THEN ''
				ELSE '/' + CONVERT(VARCHAR(20), RPR_COMP)
			END AS DIS_STR,
			RPR_OPER, RPR_REG, RPR_TYPE, RPR_TEXT,
			RPR_USER, RPR_COMPUTER, RPR_INSERT
		FROM
			dbo.RegProtocol
			INNER JOIN dbo.HostTable ON HST_ID = RPR_ID_HOST
		WHERE RPR_ID_HOST = @PTL_HOST
			AND RPR_DISTR = @PTL_NUM
			AND RPR_COMP = @PTL_COMP
		ORDER BY RPR_DATE DESC, RPR_INSERT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[REG_PROTOCOL_DISTR] TO rl_reg_protocol_r;
GO