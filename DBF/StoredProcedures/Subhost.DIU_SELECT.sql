USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[DIU_SELECT]
	@TYPE	INT,
	@DISTR	INT,
	@NAME	VARCHAR(50),
	@UNREG	BIT,
	@SH_ID	INT
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
			DIU_ID,
			SYS_ID, RN_DISTR_NUM, RN_COMP_NUM,
			SYS_SHORT_NAME + ' ' + CONVERT(VARCHAR(20), RN_DISTR_NUM) +
				CASE RN_COMP_NUM
					WHEN 1 THEN ''
					ELSE '/' + CONVERT(VARCHAR(20), RN_COMP_NUM)
				END AS DIU_DISTR_STR,
			SST_CAPTION, SN_NAME, RN_COMMENT, SH_SHORT_NAME, DIU_DATE
		FROM
			dbo.RegNodeTable a
			INNER JOIN dbo.SystemTable b ON a.RN_SYS_NAME = b.SYS_REG_NAME
			INNER JOIN dbo.SystemTypeTable c ON c.SST_NAME = a.RN_DISTR_TYPE
			INNER JOIN dbo.SystemNetCountTable d ON d.SNC_NET_COUNT = RN_NET_COUNT
			INNER JOIN dbo.SystemnetTable e ON e.SN_ID = d.SNC_ID_SN
			LEFT OUTER JOIN Subhost.Diu f ON f.DIU_ID_SYSTEM = b.SYS_ID
										AND f.DIU_DISTR = a.RN_DISTR_NUM
										AND f.DIU_COMP = a.RN_COMP_NUM
										AND (DIU_ACTIVE = 1 OR DIU_ACTIVE IS NULL)
			LEFT OUTER JOIN dbo.SubhostTable g ON g.SH_ID = f.DIU_ID_SUBHOST
		WHERE RN_SERVICE = 0 
			AND (SST_ID = @TYPE OR @TYPE IS NULL)
			AND (RN_DISTR_NUM = @DISTR OR @DISTR IS NULL)
			AND (RN_COMMENT LIKE @NAME OR @NAME IS NULL)
			AND (SH_ID = @SH_ID OR @SH_ID IS NULL)
			AND (@UNREG = 0 OR SH_ID IS NULL)
		ORDER BY SYS_ORDER,	RN_DISTR_NUM, RN_COMP_NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[DIU_SELECT] TO rl_subhost_calc;
GO
