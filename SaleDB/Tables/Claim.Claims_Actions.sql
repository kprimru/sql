USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[Claims:Actions]
(
        [Claim_Id]      Int                   NOT NULL,
        [Index]         TinyInt               NOT NULL,
        [DateTime]      DateTime              NOT NULL,
        [Personal_Id]   UniqueIdentifier          NULL,
        [Note]          VarChar(Max)              NULL,
        [Meeting]       Bit                       NULL,
        [Offer]         Bit                       NULL,
        [Mailing]       Bit                       NULL,
        CONSTRAINT [PK__Claims:Actions__3019FEA4] PRIMARY KEY CLUSTERED ([Claim_Id],[Index])
);GO
