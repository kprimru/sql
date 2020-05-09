USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[HOTLINE_CHAT_LOAD]
	@CPL		NVARCHAR(128),
	@PROFILE	NVARCHAR(128),
	@FIRST		DATETIME,
	@START		DATETIME,
	@FINISH		DATETIME,
	@FIO		NVARCHAR(256),
	@PHONE		NVARCHAR(128),
	@EMAIL		NVARCHAR(128),
	@CHAT		NVARCHAR(MAX),
	@LGN		NVARCHAR(128),
	@RIC_PERS	NVARCHAR(256),
	@LINKS		NVARCHAR(MAX)
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

		SET @FIRST = DATEADD(HOUR, 7, @FIRST)
		SET @START = DATEADD(HOUR, 7, @START)
		SET @FINISH = DATEADD(HOUR, 7, @FINISH)

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO dbo.HotlineChat(SYS, DISTR, COMP, FIRST_DATE, START, FINISH, PROFILE, FIO, EMAIL, PHONE, CHAT, LGN, RIC_PERSONAL, LINKS)
			OUTPUT inserted.ID INTO @TBL
			SELECT
				SYS, DISTR, COMP, FIRST_DATE, START, FINISH, PROFILE, FIO, EMAIL,
				PHONE, REPLACE(CHAT, CHAR(10), ''), LGN, RIC_PERSONAL, LINKS
			FROM
				(
					SELECT
						CONVERT(INT, LEFT(@CPL, CHARINDEX('_', @CPL) - 1)) AS SYS,
						CONVERT(INT,
									CASE
										WHEN CHARINDEX('_', REVERSE(@CPL)) > 3 THEN
												RIGHT(@CPL, LEN(@CPL) - CHARINDEX('_', @CPL))
										ELSE LEFT(RIGHT(@CPL, LEN(@CPL) - CHARINDEX('_', @CPL)), CHARINDEX('_', RIGHT(@CPL, LEN(@CPL) - CHARINDEX('_', @CPL))) - 1)
									END) AS DISTR,
						CASE
							WHEN CHARINDEX('_', REVERSE(@CPL)) > 3 THEN 1
							ELSE CONVERT(INT, REVERSE(LEFT(REVERSE(@CPL), CHARINDEX('_', REVERSE(@CPL)) - 1)))
						END AS COMP, @FIRST AS FIRST_DATE, @START AS START, @FINISH AS FINISH, @PROFILE AS PROFILE, @FIO AS FIO,
						@EMAIL AS EMAIL, @PHONE AS PHONE, @CHAT AS CHAT, @LGN AS LGN, @RIC_PERS AS RIC_PERSONAL, @LINKS AS LINKS
				) AS a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.HotlineChat b
					WHERE a.SYS = b.SYS AND a.DISTR = b.DISTR AND a.COMP = b.COMP
						AND a.FIRST_DATE = b.FIRST_DATE AND a.FIO = b.FIO AND a.EMAIL = b.EMAIL
						AND a.PHONE = b.PHONE AND (REPLACE(a.CHAT, CHAR(10), '') = b.CHAT OR a.CHAT = b.CHAT)
						AND a.LGN = b.LGN AND a.RIC_PERSONAL = b.RIC_PERSONAL
				)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
