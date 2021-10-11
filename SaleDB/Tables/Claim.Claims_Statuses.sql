USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[Claims:Statuses]
(
        [Claim_Id]      Int                   NOT NULL,
        [Index]         TinyInt               NOT NULL,
        [DateTime]      DateTime              NOT NULL,
        [Status_Id]     TinyInt               NOT NULL,
        [Personal_Id]   UniqueIdentifier          NULL,
        CONSTRAINT [PK__Claims:Statuses__2E31B632] PRIMARY KEY CLUSTERED ([Claim_Id],[Index])
);GO
