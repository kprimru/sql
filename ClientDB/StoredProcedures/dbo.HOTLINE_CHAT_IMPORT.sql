USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[HOTLINE_CHAT_IMPORT]
	@DATA	NVARCHAR(MAX)
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

		DECLARE @XML XML

		SET @XML = CAST(@DATA AS XML)

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
				

		INSERT INTO dbo.HotlineChat(SYS, DISTR, COMP, FIRST_DATE, START, FINISH, PROFILE, FIO, EMAIL, PHONE, CHAT, LGN, RIC_PERSONAL, LINKS)
			SELECT SYS, DISTR, COMP, FIRST_DATE, START, FINISH, PROFILE, FIO, EMAIL, PHONE, CHAT, LGN, RIC_PERSONAL, LINKS
			FROM
				(
					SELECT
						c.value('(@sys)[1]', 'INT') AS SYS,
						c.value('(@distr)[1]', 'INT') AS DISTR,
						c.value('(@comp)[1]', 'INT') AS COMP,
						CONVERT(DATETIME, c.value('(@first_date)[1]', 'NVARCHAR(64)'), 120) AS FIRST_DATE,
						CONVERT(DATETIME, c.value('(@start)[1]', 'NVARCHAR(64)'), 120) AS START,
						CONVERT(DATETIME, c.value('(@finish)[1]', 'NVARCHAR(64)'), 120) AS FINISH,
						c.value('(profile)[1]', 'NVARCHAR(256)') AS PROFILE,
						c.value('(fio)[1]', 'NVARCHAR(256)') AS FIO,
						c.value('(email)[1]', 'NVARCHAR(128)') AS EMAIL,
						c.value('(phone)[1]', 'NVARCHAR(128)') AS PHONE,
						c.value('(text)[1]', 'NVARCHAR(MAX)') AS CHAT,
						c.value('(lgn)[1]', 'NVARCHAR(128)') AS LGN,
						c.value('(personal)[1]', 'NVARCHAR(256)') AS RIC_PERSONAL,
						c.value('(links)[1]', 'NVARCHAR(MAX)') AS LINKS
					FROM @XML.nodes('root/chat') a(c)
				) AS a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.HotlineChat z
					WHERE z.SYS = a.SYS
						AND z.DISTR = a.DISTR
						AND z.COMP = a.COMP
						AND z.FIRST_DATE = a.FIRST_DATE
						AND z.START = a.START
						AND z.FINISH = a.FINISH
						AND z.FIO = a.FIO
						AND z.EMAIL = a.EMAIL
						AND z.PHONE = a.PHONE
						AND z.CHAT = a.CHAT
						AND z.LGN = a.LGN
						AND z.PROFILE = a.PROFILE
						AND z.RIC_PERSONAL = a.RIC_PERSONAL
						AND z.LINKS = a.LINKS
				)
				
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
