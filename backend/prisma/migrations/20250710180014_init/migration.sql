/*
  Warnings:

  - Made the column `date` on table `Todo` required. This step will fail if there are existing NULL values in that column.
  - Made the column `time` on table `Todo` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "Todo" ALTER COLUMN "date" SET NOT NULL,
ALTER COLUMN "time" SET NOT NULL;
