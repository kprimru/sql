USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Price].[COMMERCIAL_OFFER_TEMPLATE_MASTER_OPTIMIZE]
	@ID	UNIQUEIDENTIFIER
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
		EXEC master.dbo.GetFIOPadegAS @SURNAME, @NAME, @PATRON, 3, @DIR_SHORT_ROD OUTPUT
		
		DECLARE @SURNAME_ROD VARCHAR(256)
		DECLARE @NAME_ROD VARCHAR(256)
		DECLARE @PATRON_ROD VARCHAR(256)
			
		EXEC master.dbo.GetFIOParts @DIR_SHORT_ROD, @SURNAME_ROD OUTPUT, @NAME_ROD OUTPUT, @PATRON_ROD OUTPUT
		
		SET @DIR_SHORT_ROD = @SURNAME_ROD
		
		DECLARE @MON_CNT_1 INT
		
		SELECT @MON_CNT_1 =
			(
				SELECT MAX(SUPPORT)
				FROM 
					Price.CommercialOfferDetail z
					INNER JOIN Price.Action y ON z.ID_ACTION = y.ID
				WHERE z.ID_OFFER = @ID AND VARIANT = 1
			)	
			
		IF @MON_CNT_1 IS NULL
			SELECT @MON_CNT_1 = (SELECT MAX(MON_CNT) FROM Price.CommercialOfferDetail WHERE ID_OFFER = @ID AND VARIANT = 1)
			
		DECLARE @MON_CNT_2 INT
		
		SELECT @MON_CNT_2 =
			(
				SELECT MAX(SUPPORT)
				FROM 
					Price.CommercialOfferDetail z
					INNER JOIN Price.Action y ON z.ID_ACTION = y.ID
				WHERE z.ID_OFFER = @ID AND VARIANT = 2
			)	
			
		IF @MON_CNT_2 IS NULL
			SELECT @MON_CNT_2 = (SELECT MAX(MON_CNT) FROM Price.CommercialOfferDetail WHERE ID_OFFER = @ID AND VARIANT = 2)
		
		DECLARE @MON_STR_1 VARCHAR(64)
		
		SELECT TOP 1 @MON_STR_1 = Common.MonthString(ID_PERIOD, @MON_CNT_1)
		FROM 
			Price.CommercialOffer a
			INNER JOIN Price.CommercialOfferDetail b ON a.ID = b.ID_OFFER
		WHERE a.ID = @ID
		
		DECLARE @MON_STR_ROD_1 VARCHAR(64)
		
		EXEC master.dbo.GetAppointmentPadeg @MON_STR_1, 6, @MON_STR_ROD_1 OUTPUT
		
		DECLARE @MON_STR_2 VARCHAR(64)
		
		SELECT TOP 1 @MON_STR_2 = Common.MonthString(ID_PERIOD, @MON_CNT_2)
		FROM 
			Price.CommercialOffer a
			INNER JOIN Price.CommercialOfferDetail b ON a.ID = b.ID_OFFER
		WHERE a.ID = @ID
		
		DECLARE @MON_STR_ROD_2 VARCHAR(64)
		
		EXEC master.dbo.GetAppointmentPadeg @MON_STR_2, 6, @MON_STR_ROD_2 OUTPUT
		
		DECLARE @MANAGER VARCHAR(256)
		DECLARE @MAN_SURNAME VARCHAR(256)
		DECLARE @MAN_NAME VARCHAR(256)
		DECLARE @MAN_PATRON VARCHAR(256)
		
		SELECT @MANAGER = ManagerFullName
		FROM 
			dbo.ManagerTable a
			INNER JOIN dbo.ServiceTable b ON a.ManagerID = b.ManagerID
		WHERE ManagerLogin = ORIGINAL_LOGIN() OR ServiceLogin = ORIGINAL_LOGIN()
		
		DECLARE @MAN_SHORT VARCHAR(256)
		
		EXEC master.dbo.GetFIOParts @MANAGER, @MAN_SURNAME OUTPUT, @MAN_NAME OUTPUT, @MAN_PATRON OUTPUT
		EXEC master.dbo.GetFIOPadegAS @MAN_SURNAME, @MAN_NAME, @MAN_PATRON, 3, @MAN_SHORT OUTPUT
		
		DECLARE @SEX INT
		DECLARE @DIR_FIO VARCHAR(150)
		
		SET @DIR_FIO = @SURNAME + ' ' + @NAME + ' ' + @PATRON
		
		EXEC master.dbo.GetSex @DIR_FIO, @SEX OUTPUT
		
		SELECT 
			a.FULL_NAME AS CLIENT_SHORT, [FILE_NAME] AS TEMPLATE_FILE, OTHER,
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
			@MON_CNT_1 AS MON_CNT_1,
			@MON_STR_1 AS MON_STR_1,
			@MON_CNT_2 AS MON_CNT_2,
			@MON_STR_2 AS MON_STR_2,
			@MON_STR_ROD_1 AS MON_STR_ROD_1,
			@MON_STR_ROD_2 AS MON_STR_ROD_2,
			Common.MoneyFormat((
				SELECT SUM(DELIVERY_PRICE + SUPPORT_PRICE)
				FROM Price.CommercialOfferDetail z
				WHERE z.ID_OFFER = a.ID AND VARIANT = 1
			)) AS TOTAL_PRICE_1,
			Common.MoneyFormat((
				SELECT SUM(DELIVERY_PRICE + SUPPORT_PRICE)
				FROM Price.CommercialOfferDetail z
				WHERE z.ID_OFFER = a.ID AND VARIANT = 2
			)) AS TOTAL_PRICE_2,
			Common.MoneyFormat((
				SELECT SUM(DELIVERY_PRICE)
				FROM Price.CommercialOfferDetail z
				WHERE z.ID_OFFER = a.ID AND VARIANT = 1
			)) AS TOTAL_DELIVERY_1,
			Common.MoneyFormat((
				SELECT SUM(DELIVERY_PRICE)
				FROM Price.CommercialOfferDetail z
				WHERE z.ID_OFFER = a.ID AND VARIANT = 2
			)) AS TOTAL_DELIVERY_2,
			Common.MoneyFormat((
				SELECT SUM(SUPPORT_PRICE)
				FROM Price.CommercialOfferDetail z
				WHERE z.ID_OFFER = a.ID AND VARIANT = 1
			)) AS TOTAL_SUPPORT_1,
			Common.MoneyFormat((
				SELECT SUM(SUPPORT_PRICE)
				FROM Price.CommercialOfferDetail z
				WHERE z.ID_OFFER = a.ID AND VARIANT = 2
			)) AS TOTAL_SUPPORT_2,
			CASE ISNULL(DISCOUNT, 0)
				WHEN 0 THEN N''
				ELSE N'Скидка ' + CONVERT(NVARCHAR(32), CONVERT(INT, DISCOUNT)) + ' %'
			END AS DISCOUNT_STR,
			(
				SELECT OFFER_STRING
				FROM Security.PersonalInformation
				WHERE USER_LOGIN = ORIGINAL_LOGIN()
			) AS MANAGER_STR,
			@MAN_SHORT AS MANAGER_FULL,
			dbo.MonthRodString(DATEADD(DAY, -1, CONVERT(CHAR(6), DATEADD(MONTH, 1, DATE), 112) + '01')) AS DATE_END
		FROM 
			Price.CommercialOffer a		
			INNER JOIN Price.OfferTemplate c ON c.ID = a.ID_TEMPLATE
		WHERE a.ID = @ID
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END