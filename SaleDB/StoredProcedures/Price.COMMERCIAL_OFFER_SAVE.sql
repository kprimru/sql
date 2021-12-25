﻿USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OFFER_SAVE]
	@ID			UNIQUEIDENTIFIER OUTPUT,
	@TEMPLATE	UNIQUEIDENTIFIER,
	@VENDOR		UNIQUEIDENTIFIER,
	@DATE		SMALLDATETIME,
	@CLIENT		UNIQUEIDENTIFIER,
	@CL_NAME	NVARCHAR(1024),
	@ADDRESS	NVARCHAR(1024),
	@DIRECTOR	NVARCHAR(256),
	@DIRECTOR_POS	NVARCHAR(256),
	@NOTE		NVARCHAR(MAX),
	@DISCOUNT	DECIMAL(6, 2),
	@INFLATION	DECIMAL(6, 2),
	@SURNAME	NVARCHAR(256) = NULL,
	@NAME		NVARCHAR(256) = NULL,
	@PATRON		NVARCHAR(256) = NULL
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

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	--SET @ID = NULL

	IF @ID IS NULL
	BEGIN
		INSERT INTO Price.CommercialOffer(ID_TEMPLATE, ID_CLIENT, FULL_NAME, ADDRESS, DIRECTOR, DIRECTOR_POS, DATE, NUM, NOTE, DISCOUNT, INFLATION, PER_SURNAME, PER_NAME, PER_PATRON)
			OUTPUT inserted.ID INTO @TBL
			SELECT @TEMPLATE, @CLIENT, @CL_NAME, @ADDRESS, @DIRECTOR, @DIRECTOR_POS, @DATE, ISNULL((SELECT MAX(NUM) FROM Price.CommercialOffer WHERE STATUS = 1) + 1, 1), @NOTE, @DISCOUNT, @INFLATION, @SURNAME, @NAME, @PATRON

		SELECT @ID = ID FROM @TBL
	END
	ELSE
	BEGIN
		INSERT INTO Price.CommercialOffer(ID_MASTER, ID_TEMPLATE, ID_CLIENT, FULL_NAME, ADDRESS, DIRECTOR, DIRECTOR_POS, DATE, NUM, NOTE, DISCOUNT, INFLATION, PER_SURNAME, PER_NAME, PER_PATRON, STATUS, CREATE_DATE, CREATE_USER)
			OUTPUT inserted.ID INTO @TBL
			SELECT ID, ID_TEMPLATE, ID_CLIENT, FULL_NAME, ADDRESS, DIRECTOR, DIRECTOR_POS, DATE, NUM, NOTE, DISCOUNT, INFLATION, PER_SURNAME, PER_NAME, PER_PATRON, 2, CREATE_DATE, CREATE_USER
			FROM Price.CommercialOffer
			WHERE ID = @ID

		UPDATE Price.CommercialOffer
		SET ID_TEMPLATE	=	@TEMPLATE,
			DATE		=	@DATE,
			ID_CLIENT	=	@CLIENT,
			FULL_NAME	=	@CL_NAME,
			ADDRESS		=	@ADDRESS,
			DIRECTOR	=	@DIRECTOR,
			DIRECTOR_POS	=	@DIRECTOR_POS,
			NOTE		=	@NOTE,
			DISCOUNT	=	@DISCOUNT,
			INFLATION	=	@INFLATION,
			PER_SURNAME =	@SURNAME,
			PER_NAME	=	@NAME,
			PER_PATRON	=	@PATRON,
			CREATE_DATE	=	GETDATE(),
			CREATE_USER	=	ORIGINAL_LOGIN()
		WHERE ID = @ID

		UPDATE Price.CommercialOfferDetail
		SET ID_OFFER = (SELECT ID FROM @TBL)
		WHERE ID_OFFER = @ID

		UPDATE Price.CommercialOfferOther
		SET ID_OFFER = (SELECT ID FROM @TBL)
		WHERE ID_OFFER = @ID
	END
END
GO
GRANT EXECUTE ON [Price].[COMMERCIAL_OFFER_SAVE] TO rl_offer_w;
GO
