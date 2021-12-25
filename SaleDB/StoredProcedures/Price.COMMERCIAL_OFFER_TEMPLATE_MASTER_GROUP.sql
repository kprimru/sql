USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OFFER_TEMPLATE_MASTER_GROUP]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	DECLARE @DIR_POS	VARCHAR(256)


	DECLARE @SURNAME	VARCHAR(256)
	DECLARE	@NAME		VARCHAR(256)
	DECLARE @PATRON		VARCHAR(256)

	DECLARE @MON	VARCHAR(64)

	SELECT @DIR_POS = DIRECTOR_POS, @SURNAME = PER_SURNAME, @NAME = PER_NAME, @PATRON = PER_PATRON, @MON = DATENAME(MONTH, DATE)
	FROM Price.CommercialOffer
	WHERE ID = @ID

	DECLARE @DIR_SHORT_ROD	VARCHAR(256)
	DECLARE @DIR_POS_ROD	VARCHAR(256)
	DECLARE @DIR_IO			VARCHAR(256)

	DECLARE @MON_ROD	VARCHAR(64)

	EXEC master.dbo.GetAppointmentPadeg @MON, 2, @MON_ROD OUTPUT

	EXEC master.dbo.GetAppointmentPadeg @DIR_POS, 3, @DIR_POS_ROD OUTPUT
	EXEC master.dbo.GetFIOPadegAS @SURNAME, '', '', 3, @DIR_SHORT_ROD OUTPUT

	DECLARE @MON_CNT INT

	SELECT @MON_CNT =
		(
			SELECT TOP 1 SUPPORT
			FROM
				Price.CommercialOfferDetail z
				INNER JOIN Price.Action y ON z.ID_ACTION = y.ID
			WHERE z.ID_OFFER = @ID
		)

	DECLARE @MON_STR VARCHAR(64)

	SELECT TOP 1 @MON_STR = Common.MonthString(ID_PERIOD, @MON_CNT)
	FROM
		Price.CommercialOffer a
		INNER JOIN Price.CommercialOfferDetail b ON a.ID = b.ID_OFFER
	WHERE a.ID = @ID

	DECLARE @MON_STR_ROD VARCHAR(64)

	EXEC master.dbo.GetAppointmentPadeg @MON_STR, 6, @MON_STR_ROD OUTPUT

	DECLARE @MANAGER VARCHAR(256)
	DECLARE @MAN_SURNAME VARCHAR(256)
	DECLARE @MAN_NAME VARCHAR(256)
	DECLARE @MAN_PATRON VARCHAR(256)
	DECLARE @MAN_PHONE	VARCHAR(256)
	DECLARE @MAN_PHONE_OF VARCHAR(256)

	SELECT
		@MANAGER = SURNAME + ' ' + NAME + ' ' + PATRON,
		@MAN_SURNAME = SURNAME,
		@MAN_NAME = NAME,
		@MAN_PATRON = PATRON,
		@MAN_PHONE = PHONE,
		@MAN_PHONE_OF = PHONE_OFFICE
	FROM
		Personal.OfficePersonal a
	WHERE [LOGIN] = ORIGINAL_LOGIN()

	DECLARE @MAN_SHORT VARCHAR(256)

	EXEC master.dbo.GetFIOPadegAS @MAN_SURNAME, @MAN_NAME, @MAN_PATRON, 3, @MAN_SHORT OUTPUT

	DECLARE @SEX INT
	DECLARE @DIR_FIO VARCHAR(150)

	SET @DIR_FIO = @SURNAME + ' ' + @NAME + ' ' + @PATRON

	EXEC master.dbo.GetSex @DIR_FIO, @SEX OUTPUT

	SELECT
		d.NUMBER /*a.FULL_NAME */AS CLIENT_SHORT, [FILE_NAME] AS TEMPLATE_FILE,
		@DIR_POS_ROD AS DIRECTOR_POS,
		@DIR_SHORT_ROD + ' ' + LEFT(@NAME, 1) + '.' + LEFT(@PATRON, 1) + '.' AS DIRECTOR_SHORT,
		CASE
			WHEN @NAME <> '' OR @PATRON <> '' THEN
				CASE @SEX WHEN 1 THEN 'Уважаемый '
				ELSE 'Уважаемая '
			END + @NAME + ' ' + @PATRON
			ELSE ''
		END AS DIRECTOR_IO, a.FULL_NAME AS CLIENT,
		@MON_ROD AS CL_MONTH, DATEPART(DAY, DATE) AS CL_DAY, DATEPART(YEAR, DATE) AS CL_YEAR,
		(
			SELECT TOP 1 y.NAME
			FROM
				Price.CommercialOfferDetail z
				INNER JOIN Common.Tax y ON z.ID_TAX = y.ID
			WHERE z.ID_OFFER = a.ID
		) AS TAX_STR,
		@MON_CNT AS MON_CNT,
		CASE @MON_CNT
			WHEN 1 THEN CONVERT(VARCHAR(20), @MON_CNT)
			ELSE CONVERT(VARCHAR(20), @MON_CNT) + '-х'
		END AS MON_CNT_STR,
		@MON_STR AS MON_STR,
		CASE ISNULL(DISCOUNT, 0)
			WHEN 0 THEN N''
			ELSE N'Скидка ' + CONVERT(NVARCHAR(32), CONVERT(INT, DISCOUNT)) + ' %'
		END AS DISCOUNT_STR,
		@MON_STR_ROD AS MON_STR_ROD,
		Common.MoneyFormat((
			SELECT SUM(SUPPORT_PRICE)
			FROM Price.CommercialOfferDetail z
			WHERE z.ID_OFFER = a.ID
		)) AS TOTAL_SUPPORT,
		Common.MoneyFormat((
			SELECT SUM(SUPPORT_PRICE + DELIVERY_PRICE)
			FROM Price.CommercialOfferDetail z
			WHERE z.ID_OFFER = a.ID
		)) AS TOTAL_PRICE,
		Common.MoneyFormat((
			SELECT SUM(DELIVERY_PRICE)
			FROM Price.CommercialOfferDetail z
			WHERE z.ID_OFFER = a.ID
		)) AS TOTAL_DELIVERY,
		Common.MoneyFormat((
			SELECT SUM(SUPPORT_FURTHER)
			FROM Price.CommercialOfferDetail z
			WHERE z.ID_OFFER = a.ID
		)) AS TOTAL_FURTHER,
		Common.MoneyFormat((
			SELECT SUM(DELIVERY_ORIGIN)
			FROM Price.CommercialOfferDetail z
			WHERE z.ID_OFFER = a.ID
		)) AS TOTAL_DELIVERY_ORIGIN,
		Common.MoneyFormat((
			SELECT SUM(DELIVERY_ORIGIN + SUPPORT_PRICE)
			FROM Price.CommercialOfferDetail z
			WHERE z.ID_OFFER = a.ID
		)) AS TOTAL_ORIGIN,
		@MAN_SHORT AS MANAGER_FULL,
		@MAN_PHONE AS MANAGER_PHONE, @MAN_PHONE_OF AS MANAGER_PHONE_OFFICE,
		'___' + Common.MonthRodString(DATEADD(DAY, -1, CONVERT(CHAR(6), DATEADD(MONTH, 1, DATE), 112) + '01')) AS DATE_END,
		REVERSE(STUFF(REVERSE((
			SELECT
				CONVERT(NVARCHAR(10), RN) + '. ' + SYS_FULL_STR + CHAR(10) + CHAR(10)
			FROM
				Price.CommercialOfferView a
				LEFT OUTER JOIN System.Systems b ON a.ID_SYSTEM = b.ID
				--LEFT OUTER JOIN dbo.SystemTable c ON a.ID_OLD_SYSTEM = c.SystemID
				LEFT OUTER JOIN System.Systems d ON a.ID_NEW_SYSTEM = d.ID
				LEFT OUTER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable z ON z.SystemBaseName = b.REG
				LEFT OUTER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable y ON y.SystemBaseName = d.REG
				LEFT OUTER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemNote e ON e.ID_SYSTEM = z.SystemID
				LEFT OUTER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemNote f ON f.ID_SYSTEM = y.SystemID
				LEFT OUTER JOIN Price.Action g ON g.ID = a.ID_ACTION
			WHERE ID_OFFER = @ID
			--ORDER BY b.SystemOrder, c.SystemOrder
			ORDER BY b.ORD
				/*CASE
					WHEN RN = 1 THEN 2
					WHEN RN = (SELECT MAX(RN) FROM Price.CommercialOfferView WHERE ID_OFFER = @ID) THEN 1
					ELSE RN
				END*/ FOR XML PATH('')
		)), 1, 2, '')) AS SYS_STR
	FROM
		Price.CommercialOffer a
		--INNER JOIN dbo.Vendor b ON a.ID_VENDOR = b.ID
		INNER JOIN Price.OfferTemplate c ON c.ID = a.ID_TEMPLATE
		INNER JOIN Client.Company d ON a.ID_CLIENT = d.ID
	WHERE a.ID = @ID
END
GO
