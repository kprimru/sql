USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Price].[COMMERCIAL_OFFER_SAVE]
	@ID			UNIQUEIDENTIFIER OUTPUT,
	@TEMPLATE	UNIQUEIDENTIFIER,
	@VENDOR		UNIQUEIDENTIFIER,
	@DATE		SMALLDATETIME,
	@CLIENT		INT,
	@CL_NAME	NVARCHAR(1024),
	@ADDRESS	NVARCHAR(1024),
	@DIRECTOR	NVARCHAR(256),
	@DIRECTOR_POS	NVARCHAR(256),
	@NOTE		NVARCHAR(MAX),
	@DISCOUNT	DECIMAL(6, 2),
	@INFLATION	DECIMAL(6, 2),
	@SURNAME	NVARCHAR(256) = NULL,
	@NAME		NVARCHAR(256) = NULL,
	@PATRON		NVARCHAR(256) = NULL,
	@OTHER		BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)
	
	IF @ID IS NULL
	BEGIN
		INSERT INTO Price.CommercialOffer(ID_TEMPLATE, ID_VENDOR, ID_CLIENT, FULL_NAME, ADDRESS, DIRECTOR, DIRECTOR_POS, DATE, NUM, NOTE, DISCOUNT, INFLATION, PER_SURNAME, PER_NAME, PER_PATRON, OTHER)
			OUTPUT inserted.ID INTO @TBL
			SELECT @TEMPLATE, @VENDOR, @CLIENT, @CL_NAME, @ADDRESS, @DIRECTOR, @DIRECTOR_POS, @DATE, ISNULL((SELECT MAX(NUM) FROM Price.CommercialOffer WHERE STATUS = 1) + 1, 1), @NOTE, @DISCOUNT, @INFLATION, @SURNAME, @NAME, @PATRON, @OTHER
			
		SELECT @ID = ID FROM @TBL
	END
	ELSE
	BEGIN
		INSERT INTO Price.CommercialOffer(ID_MASTER, ID_TEMPLATE, ID_VENDOR, ID_CLIENT, FULL_NAME, ADDRESS, DIRECTOR, DIRECTOR_POS, DATE, NUM, NOTE, DISCOUNT, INFLATION, PER_SURNAME, PER_NAME, PER_PATRON, STATUS, CREATE_DATE, CREATE_USER, OTHER)
			OUTPUT inserted.ID INTO @TBL
			SELECT ID, ID_TEMPLATE, ID_VENDOR, ID_CLIENT, FULL_NAME, ADDRESS, DIRECTOR, DIRECTOR_POS, DATE, NUM, NOTE, DISCOUNT, INFLATION, PER_SURNAME, PER_NAME, PER_PATRON, 2, CREATE_DATE, CREATE_USER, OTHER
			FROM Price.CommercialOffer
			WHERE ID = @ID
			
		UPDATE Price.CommercialOffer
		SET ID_TEMPLATE	=	@TEMPLATE, 
			ID_VENDOR	=	@VENDOR, 
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
			OTHER		=	@OTHER,
			CREATE_DATE	=	GETDATE(), 
			CREATE_USER	=	ORIGINAL_LOGIN()
		WHERE ID = @ID
		
		UPDATE Price.CommercialOfferDetail
		SET ID_OFFER = (SELECT ID FROM @TBL)
		WHERE ID_OFFER = @ID
	END
END