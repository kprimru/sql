USE [VMIClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLAIM_SELECT]
	@NAME	NVARCHAR(128),
	@START	SMALLDATETIME,
	@FINISH	SMALLDATETIME,
	@STATUS	NVARCHAR(MAX),
	@TYPE	NVARCHAR(MAX),
	@PERS	NVARCHAR(128) = NULL,
	@MEETING	INT = NULL,
	@OFFER		INT = NULL,
	@MAILING	INT = NULL,
	@NUM        INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SET @FINISH = DATEADD(DAY, 1, @FINISH)

	SELECT
		a.ID, a.TP, b.NAME, a.NUM, a.DATE, a.FIO, a.CLIENT, a.CITY, a.EMAIL, a.PHONE, c.NAME AS STATUS, NOTE, DISTR, PERSONAL, ID_STATUS,
		(
			SELECT MAX(DATE)
			FROM dbo.ClaimEmail z
			WHERE a.ID = z.ID_CLAIM
		) AS SEND_DATE,
		c.IND, a.SPECIAL, a.ACTIONS, a.PAGE_URL, a.PAGE_TITLE, a.WORK_DATE, a.DELIVERY_DATE,
		MEETING, OFFER, MAILING,
		CASE MEETING
			WHEN 1 THEN '��'
			WHEN 0 THEN '���'
			ELSE '�����.'
		END AS MEET,
		CASE OFFER
			WHEN 1 THEN '��'
			WHEN 0 THEN '���'
			ELSE '�����.'
		END AS OFFR,
		a.COMPANY,
		CASE MAILING
			WHEN 1 THEN '��'
			WHEN 0 THEN '���'
			ELSE '�����.'
		END AS MLNG
	FROM
		dbo.Claim a
		INNER JOIN dbo.ClaimTypeView b ON a.TP = b.TP
		LEFT OUTER JOIN dbo.ClaimStatus c ON a.ID_STATUS = c.ID
	WHERE
	        (NUM = @NUM OR @NUM IS NULL)
		AND (PERSONAL = @NAME OR ISNULL(@NAME, '') = '')
		AND (a.DATE >= @START OR @START IS NULL)
		AND (a.DATE < @FINISH OR @FINISH IS NULL)
		AND (c.ID IN (SELECT ID FROM dbo.TableGUIDFromXML(@STATUS)) OR @STATUS IS NULL)
		AND (a.TP IN (SELECT ID FROM dbo.TableIntFromXML(@TYPE)) OR @TYPE IS NULL)
		AND (PERSONAL = @PERS OR @PERS IS NULL OR @PERS = '')
		AND (@MEETING IS NULL OR @MEETING = -1 OR @MEETING = 0 OR @MEETING = 1 AND MEETING = 1 OR @MEETING = 2 AND MEETING = 0)
		AND (@OFFER IS NULL OR @OFFER = -1 OR @OFFER = 0 OR @OFFER = 1 AND OFFER = 1 OR @OFFER = 2 AND OFFER = 0)
		AND (@MAILING IS NULL OR @MAILING = -1 OR @MAILING = 0 OR @MAILING = 1 AND MAILING = 1 OR @MAILING = 2 AND MAILING = 0)
	ORDER BY a.DATE DESC, a.NUM
END
GO
GRANT EXECUTE ON [dbo].[CLAIM_SELECT] TO rl_read;
GO