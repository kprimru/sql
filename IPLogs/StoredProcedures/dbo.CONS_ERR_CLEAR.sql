USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CONS_ERR_CLEAR]
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

	    DELETE
	    FROM dbo.ConsErr
	    WHERE ID_USR IN
		    (
			    SELECT UF_ID
			    FROM
				    (
					    SELECT UF_ID, UF_SYS, UF_DISTR, UF_COMP, ROW_NUMBER() OVER(PARTITION BY UF_SYS, UF_DISTR, UF_COMP ORDER BY UF_DATE DESC) AS RN, UF_DATE
					    FROM dbo.USRFiles
				    ) AS o_O
			    WHERE RN > 2
		    )
    
	    DELETE
	    FROM dbo.ConsErr
	    WHERE NOT EXISTS
		    (
			    SELECT *
			    FROM dbo.USRFiles
			    WHERE UF_ID = ID_USR
		    )
    
	    DELETE
	    FROM dbo.ConsErr
	    WHERE ID_USR IN
		    (
			    SELECT UF_ID
			    FROM dbo.USRFiles
			    WHERE UF_DATE < DATEADD(MONTH, -6, GETDATE())
		    )
    
	    DELETE
	    FROM dbo.USRFiles
	    WHERE UF_DATE < DATEADD(MONTH, -6, GETDATE())

	    DELETE
	    FROM dbo.LogFiles
	    WHERE LF_DATE < DATEADD(MONTH, -6, GETDATE())

	    EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
